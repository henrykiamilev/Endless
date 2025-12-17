import SwiftUI
import AVFoundation
import Vision
import CoreML
import UIKit

// Wrap the controller for SwiftUI
struct PoseSessionCameraView: UIViewControllerRepresentable {
    @Binding var isSessionActive: Bool
    var onExported: (URL) -> Void
    var onShotCaptured: () -> Void

    func makeUIViewController(context: Context) -> PoseSessionController {
        let vc = PoseSessionController()
        vc.onExported = onExported
        vc.onShotCaptured = onShotCaptured
        return vc
    }

    func updateUIViewController(_ uiViewController: PoseSessionController, context: Context) {
        uiViewController.setSessionActive(isSessionActive)
    }
}

// MARK: - Main controller
final class PoseSessionController: UIViewController,
                                   AVCaptureVideoDataOutputSampleBufferDelegate,
                                   AVCaptureFileOutputRecordingDelegate {
    // UI
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let overlayLayer = CAShapeLayer()
    private let hud = UILabel()

    // Camera
    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let movieOutput = AVCaptureMovieFileOutput()

    // Vision / Model
    private let visionQueue = DispatchQueue(label: "vision.queue")
    private let poseReq = VNDetectHumanBodyPoseRequest()
    private lazy var mlModel: MLModel = {
        let cfg = MLModelConfiguration()
        cfg.computeUnits = .all
        return try! GolfPoseClassifier(configuration: cfg).model
    }()
    // Expected input length (read from model metadata)
    private lazy var expectedInputLength: Int = {
        let input = mlModel.modelDescription.inputDescriptionsByName["features"]
        let shape = input?.multiArrayConstraint?.shape
        if let n = shape?.last?.intValue { return n }
        return 37
    }()
    private let featureBuilder = FeatureBuilder()

    // Session callbacks
    var onExported: ((URL) -> Void)?
    var onShotCaptured: (() -> Void)?

    // Trigger state
    enum Phase { case idle, waitingReady, recordingSwing, postEndSwing }
    private var phase: Phase = .idle

    // Debounce settings
    private let readyHold: TimeInterval = 0.1
    private let endHold: TimeInterval = 0.1
    private let postEndDuration: TimeInterval = 4.0
    private let cooldown: TimeInterval = 5.0

    private var labelHistory: [(ts: CFTimeInterval, label: String)] = []
    private var lastPhaseChange: CFTimeInterval = 0
    private var postEndTimer: Timer?

    // Captured swing clips
    private var clipURLs: [URL] = []
    private var currentClipURL: URL?

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupOverlay()
        setupHUD()
        session.startRunning()
        enter(.waitingReady)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        overlayLayer.frame = view.bounds
    }

    func setSessionActive(_ active: Bool) {
        if active {
            if phase == .idle { enter(.waitingReady) }
        } else {
            stopRecordingIfNeeded()
            stitchAllClips { [weak self] url in
                guard let self, let url else { return }
                self.onExported?(url)
                self.clipURLs.removeAll()
                self.enter(.idle)
            }
        }
    }

    // MARK: - Setup Camera
    private func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input)
        else { session.commitConfiguration(); return }
        session.addInput(input)

        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.buffer"))
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        guard session.canAddOutput(videoOutput) else { session.commitConfiguration(); return }
        session.addOutput(videoOutput)

        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        }

        if let conn = videoOutput.connection(with: .video) {
            if conn.isVideoOrientationSupported { conn.videoOrientation = .portrait }
            if conn.isVideoMirroringSupported { conn.isVideoMirrored = true }
        }
        if let conn = movieOutput.connection(with: .video) {
            if conn.isVideoOrientationSupported { conn.videoOrientation = .portrait }
            if conn.isVideoMirroringSupported { conn.isVideoMirrored = true }
        }

        session.commitConfiguration()

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
    }

    private func setupOverlay() {
        overlayLayer.frame = view.bounds
        overlayLayer.strokeColor = UIColor.systemGreen.cgColor
        overlayLayer.fillColor = UIColor.clear.cgColor
        overlayLayer.lineWidth = 3
        view.layer.addSublayer(overlayLayer)
    }

    private func setupHUD() {
        hud.text = "—"
        hud.textColor = .white
        hud.font = .systemFont(ofSize: 16, weight: .semibold)
        hud.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        hud.layer.cornerRadius = 8
        hud.layer.masksToBounds = true
        hud.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hud)
        NSLayoutConstraint.activate([
            hud.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hud.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            hud.heightAnchor.constraint(equalToConstant: 28),
            hud.widthAnchor.constraint(greaterThanOrEqualToConstant: 160)
        ])
        updateHUD()
    }

    // MARK: - AVCapture delegate
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pb = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let orientation: CGImagePropertyOrientation = .leftMirrored
        let handler = VNImageRequestHandler(cvPixelBuffer: pb, orientation: orientation)

        visionQueue.async {
            do {
                try handler.perform([self.poseReq])
                guard let obs = self.poseReq.results?.first else { return }

                self.drawPose(obs)

                guard let feats = self.featureBuilder.makeFeatures(from: obs),
                      feats.count == self.expectedInputLength else { return }

                let arr = try MLMultiArray(shape: [1, NSNumber(value: feats.count)], dataType: .double)
                for (i, v) in feats.enumerated() { arr[i] = NSNumber(value: v) }
                let provider = try MLDictionaryFeatureProvider(dictionary: ["features": arr])
                let out = try self.mlModel.prediction(from: provider)
                let label = out.featureValue(for: "classLabel")?.stringValue ?? "other"

                self.handle(label: label)

            } catch {
                // ignore per-frame errors
            }
        }
    }

    // MARK: - Trigger logic
    private func handle(label: String) {
        let now = CACurrentMediaTime()
        labelHistory.append((now, label))
        let cutoff = now - 2.5
        labelHistory.removeAll { $0.ts < cutoff }

        let readyDur = continuousDuration(of: "ready", now: now)
        let endDur = continuousDuration(of: "endswing", now: now)

        switch phase {
        case .idle:
            break
        case .waitingReady:
            if readyDur >= readyHold && (now - lastPhaseChange) > cooldown {
                startNewClip()
                enter(.recordingSwing)
            }
        case .recordingSwing:
            if endDur >= endHold {
                schedulePostEndStop()
                enter(.postEndSwing)
            }
        case .postEndSwing:
            break
        }

        DispatchQueue.main.async { self.updateHUD(currentLabel: label) }
    }

    private func continuousDuration(of target: String, now: CFTimeInterval) -> TimeInterval {
        var last = now
        for item in labelHistory.reversed() {
            if item.label == target {
                last = item.ts
            } else {
                break
            }
        }
        return max(0, now - last)
    }

    private func schedulePostEndStop() {
        postEndTimer?.invalidate()
        DispatchQueue.main.async {
            self.postEndTimer = Timer.scheduledTimer(withTimeInterval: self.postEndDuration,
                                                     repeats: false) { [weak self] _ in
                guard let self = self else { return }
                self.stopRecordingIfNeeded()
                self.enter(.waitingReady)
            }
            RunLoop.main.add(self.postEndTimer!, forMode: .common)
        }
    }

    // MARK: - Recording
    private func startNewClip() {
        guard !movieOutput.isRecording else { return }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("swing-\(UUID().uuidString).mov")
        currentClipURL = url
        movieOutput.startRecording(to: url, recordingDelegate: self)
    }

    private func stopRecordingIfNeeded() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
        }
    }

    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        if error == nil {
            clipURLs.append(outputFileURL)
            DispatchQueue.main.async { self.onShotCaptured?() }
        } else {
            try? FileManager.default.removeItem(at: outputFileURL)
        }
        currentClipURL = nil
    }

    // MARK: - Stitching
    private func stitchAllClips(shotLabels: [String]? = nil,
                                completion: @escaping (URL?) -> Void) {
        guard !clipURLs.isEmpty else { completion(nil); return }

        let mix = AVMutableComposition()
        guard let compVideo = mix.addMutableTrack(withMediaType: .video,
                                                  preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion(nil); return
        }

        var cursor = CMTime.zero
        var renderSize = CGSize(width: 1080, height: 1920)
        var layerInstructions: [AVMutableVideoCompositionLayerInstruction] = []

        for (idx, url) in clipURLs.enumerated() {
            let asset = AVAsset(url: url)
            guard let src = asset.tracks(withMediaType: .video).first else { continue }
            if idx == 0 {
                let natural = src.naturalSize.applying(src.preferredTransform)
                renderSize = CGSize(width: abs(natural.width), height: abs(natural.height))
            }

            let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            try? compVideo.insertTimeRange(timeRange, of: src, at: cursor)

            let layerInst = AVMutableVideoCompositionLayerInstruction(assetTrack: compVideo)
            var t = src.preferredTransform
            t = t.scaledBy(x: 1, y: -1).translatedBy(x: 0, y: -renderSize.width)
            layerInst.setTransform(t, at: cursor)
            layerInstructions.append(layerInst)

            cursor = cursor + asset.duration
        }

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: cursor)
        instruction.layerInstructions = layerInstructions

        let videoComp = AVMutableVideoComposition()
        videoComp.renderSize = renderSize
        videoComp.frameDuration = CMTime(value: 1, timescale: 30)
        videoComp.instructions = [instruction]

        let parent = CALayer()
        parent.frame = CGRect(origin: .zero, size: renderSize)

        let videoLayer = CALayer()
        videoLayer.frame = parent.frame
        parent.addSublayer(videoLayer)

        let tagsContainer = CALayer()
        tagsContainer.frame = parent.bounds
        parent.addSublayer(tagsContainer)

        if !clipURLs.isEmpty {
            var begin = CFTimeInterval(0)
            for (i, url) in clipURLs.enumerated() {
                let asset = AVAsset(url: url)
                let d = CMTimeGetSeconds(asset.duration)

                let tag = CATextLayer()
                tag.contentsScale = UIScreen.main.scale
                tag.alignmentMode = .center
                tag.font = UIFont.systemFont(ofSize: 45, weight: .semibold)
                tag.fontSize = 45
                tag.foregroundColor = UIColor.white.cgColor
                tag.backgroundColor = UIColor.black.cgColor
                tag.cornerRadius = 8
                tag.masksToBounds = true

                let label = (shotLabels != nil && i < shotLabels!.count) ? shotLabels![i] : "Shot \(i+1)"
                tag.string = label

                let pad: CGFloat = 24
                let textW: CGFloat = 150
                let textH: CGFloat = 75
                tag.frame = CGRect(x: renderSize.width - textW - pad, y: renderSize.height - textH - pad, width: textW, height: textH)
                tag.contentsGravity = .center
                tag.beginTime = AVCoreAnimationBeginTimeAtZero + begin
                tag.duration = d

                tagsContainer.addSublayer(tag)
                begin += d
            }
        }

        if let logo = UIImage(named: "AppLogoCircle")?.cgImage {
            let logoLayer = CALayer()
            logoLayer.contents = logo
            logoLayer.contentsGravity = .resizeAspect
            let pad: CGFloat = 24
            let logoW: CGFloat = 120
            let logoH: CGFloat = 120
            logoLayer.frame = CGRect(x: renderSize.width - logoW - pad, y: pad, width: logoW, height: logoH)
            logoLayer.opacity = 0.95
            parent.addSublayer(logoLayer)
        }

        videoComp.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: parent
        )

        let outURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("golf-session-\(UUID().uuidString).mp4")
        guard let exporter = AVAssetExportSession(asset: mix, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil); return
        }
        exporter.outputURL = outURL
        exporter.outputFileType = .mp4
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = videoComp

        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                completion(exporter.status == .completed ? outURL : nil)
                for u in self.clipURLs { try? FileManager.default.removeItem(at: u) }
            }
        }
    }

    // MARK: - Helpers
    private func enter(_ newPhase: Phase) {
        phase = newPhase
        lastPhaseChange = CACurrentMediaTime()
        DispatchQueue.main.async {
            self.updateHUD()
            self.updateOverlayColor(for: newPhase)
        }
    }

    private func updateOverlayColor(for phase: Phase) {
        let newColor = colorForPhase(phase).cgColor
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        overlayLayer.strokeColor = newColor
        CATransaction.commit()
    }

    private func colorForPhase(_ phase: Phase) -> UIColor {
        switch phase {
        case .idle, .postEndSwing: return .systemYellow
        case .waitingReady: return .systemRed
        case .recordingSwing: return .systemGreen
        }
    }

    private func updateHUD(currentLabel: String? = nil) {
        let p: String = {
            switch phase {
            case .idle: return "Idle"
            case .waitingReady: return "Waiting..."
            case .recordingSwing: return "Recording swing..."
            case .postEndSwing: return "Post-endswing..."
            }
        }()
        hud.text = currentLabel != nil ? "\(p) | \(currentLabel!)" : p
        hud.textAlignment = .center
    }

    private func drawPose(_ obs: VNHumanBodyPoseObservation) {
        guard let pts = try? obs.recognizedPoints(.all) else { return }
        let minConf: Float = 0.1
        let pairs: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = [
            (.neck, .leftShoulder), (.leftShoulder, .leftElbow), (.leftElbow, .leftWrist),
            (.neck, .rightShoulder), (.rightShoulder, .rightElbow), (.rightElbow, .rightWrist),
            (.neck, .root), (.root, .leftHip), (.leftHip, .leftKnee), (.leftKnee, .leftAnkle),
            (.root, .rightHip), (.rightHip, .rightKnee), (.rightKnee, .rightAnkle)
        ]
        let path = UIBezierPath()
        func devPoint(_ p: CGPoint) -> CGPoint {
            let flipped = CGPoint(x: p.x, y: 1 - p.y)
            return previewLayer.layerPointConverted(fromCaptureDevicePoint: flipped)
        }
        for (a, b) in pairs {
            guard let pa = pts[a], pa.confidence >= minConf,
                  let pb = pts[b], pb.confidence >= minConf else { continue }
            let p1 = devPoint(CGPoint(x: CGFloat(pa.location.x), y: CGFloat(pa.location.y)))
            let p2 = devPoint(CGPoint(x: CGFloat(pb.location.x), y: CGFloat(pb.location.y)))
            path.move(to: p1); path.addLine(to: p2)
        }
        DispatchQueue.main.async { self.overlayLayer.path = path.cgPath }
    }
}

// MARK: - Features
fileprivate final class FeatureBuilder {
    private let joints: [VNHumanBodyPoseObservation.JointName] = [
        .nose, .neck,
        .leftShoulder, .rightShoulder,
        .leftElbow, .rightElbow,
        .leftWrist, .rightWrist,
        .leftHip, .rightHip,
        .leftKnee, .rightKnee,
        .leftAnkle, .rightAnkle
    ]
    private let minConf: Float = 0.1

    func makeFeatures(from obs: VNHumanBodyPoseObservation) -> [Double]? {
        guard let pts = try? obs.recognizedPoints(.all) else { return nil }
        guard let lHip = pts[.leftHip], lHip.confidence >= minConf,
              let rHip = pts[.rightHip], rHip.confidence >= minConf,
              let lSh = pts[.leftShoulder], lSh.confidence >= minConf,
              let rSh = pts[.rightShoulder], rSh.confidence >= minConf else { return nil }

        let pelvis = CGPoint(x: CGFloat((lHip.location.x + rHip.location.x)/2),
                             y: CGFloat((lHip.location.y + rHip.location.y)/2))
        let shMid = CGPoint(x: CGFloat((lSh.location.x + rSh.location.x)/2),
                            y: CGFloat((lSh.location.y + rSh.location.y)/2))
        let torso = max(1e-6, hypot(shMid.x - pelvis.x, shMid.y - pelvis.y))

        var dict: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        for j in joints {
            if let p = pts[j], p.confidence >= minConf {
                let g = CGPoint(x: CGFloat(p.location.x), y: CGFloat(p.location.y))
                dict[j] = CGPoint(x: (g.x - pelvis.x)/torso, y: (g.y - pelvis.y)/torso)
            } else {
                dict[j] = .zero
            }
        }
        var feats: [Double] = []
        for j in joints {
            let p = dict[j] ?? .zero
            feats.append(Double(p.x)); feats.append(Double(p.y))
        }

        guard let neck = dict[.neck],
              let ls = dict[.leftShoulder], let rs = dict[.rightShoulder],
              let lh = dict[.leftHip], let rh = dict[.rightHip],
              let le = dict[.leftElbow], let re = dict[.rightElbow],
              let lw = dict[.leftWrist], let rw = dict[.rightWrist],
              let lk = dict[.leftKnee], let rk = dict[.rightKnee],
              let la = dict[.leftAnkle], let ra = dict[.rightAnkle] else { return nil }

        func lineAngle(_ a: CGPoint, _ b: CGPoint) -> Double {
            let v = CGVector(dx: b.x - a.x, dy: b.y - a.y)
            return Double(atan2(v.dy, v.dx) * 180 / .pi)
        }
        func angle(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Double {
            let v1 = CGVector(dx: a.x - b.x, dy: a.y - b.y)
            let v2 = CGVector(dx: c.x - b.x, dy: c.y - b.y)
            let den = (hypot(v1.dx, v1.dy) * hypot(v2.dx, v2.dy) + 1e-6)
            let cosv = max(-1.0, min(1.0, Double((v1.dx*v2.dx + v1.dy*v2.dy) / den)))
            return acos(cosv) * 180 / .pi
        }
        func angleToVertical(_ from: CGPoint, _ to: CGPoint) -> Double {
            let v = CGVector(dx: to.x - from.x, dy: to.y - from.y)
            let den = max(1e-6, hypot(v.dx, v.dy))
            let cosv = max(-1.0, min(1.0, Double(v.dy / den)))
            return acos(cosv) * 180 / .pi
        }

        let shoulderLine = lineAngle(ls, rs)
        let hipLine = lineAngle(lh, rh)
        let trunkPitch = angleToVertical(CGPoint(x:(lh.x+rh.x)/2, y:(lh.y+rh.y)/2), neck)
        let elbowL = angle(ls, le, lw)
        let elbowR = angle(rs, re, rw)
        let kneeL = angle(lh, lk, la)
        let kneeR = angle(rh, rk, ra)
        feats += [shoulderLine, hipLine, trunkPitch, elbowL, elbowR, kneeL, kneeR]

        let handsHeightVsShoulders = Double(((lw.y + rw.y)/2.0) - ((ls.y + rs.y)/2.0))
        let wristDistFromNeck = Double((hypot(lw.x - neck.x, lw.y - neck.y) +
                                        hypot(rw.x - neck.x, rw.y - neck.y)) / 2.0)
        feats += [handsHeightVsShoulders, wristDistFromNeck]
        return feats
    }
}
