import Foundation
import AVFoundation
import Vision
import CoreML
import UIKit
import Combine

/// Generates highlight reels from user's golf videos
class HighlightReelGenerator: ObservableObject {
    static let shared = HighlightReelGenerator()

    @Published var isGenerating = false
    @Published var generationProgress: Double = 0
    @Published var currentStatus: String = "Preparing..."

    private let analysisQueue = DispatchQueue(label: "com.endless.highlightGeneration", qos: .userInitiated)
    private let swingAnalyzer = SwingAnalyzer.shared

    private init() {}

    // MARK: - Public API

    /// Generates a highlight reel from the user's videos
    func generateHighlightReel(
        from videos: [Video],
        config: HighlightReelConfig
    ) async throws -> HighlightReelResult {
        await MainActor.run {
            isGenerating = true
            generationProgress = 0
            currentStatus = "Analyzing videos..."
        }

        defer {
            Task { @MainActor in
                isGenerating = false
                generationProgress = 1.0
                currentStatus = "Complete!"
            }
        }

        // Step 1: Filter videos by course if specified
        var filteredVideos = videos
        if !config.selectedCourses.isEmpty {
            filteredVideos = filterVideosByCourse(videos, courses: config.selectedCourses)
        }

        guard !filteredVideos.isEmpty else {
            throw HighlightReelError.noVideosFound
        }

        await MainActor.run {
            generationProgress = 0.1
            currentStatus = "Finding best shots..."
        }

        // Step 2: Extract and analyze clips from each video
        var allClips: [HighlightClip] = []

        for (index, video) in filteredVideos.enumerated() {
            guard let videoPath = video.videoFileName else { continue }

            let clips = await extractClipsFromVideo(at: videoPath, videoDate: parseDate(video.date))

            allClips.append(contentsOf: clips)

            let progress = 0.1 + (Double(index + 1) / Double(filteredVideos.count)) * 0.4
            await MainActor.run {
                generationProgress = progress
            }
        }

        guard !allClips.isEmpty else {
            throw HighlightReelError.noClipsExtracted
        }

        await MainActor.run {
            generationProgress = 0.5
            currentStatus = "Selecting best clips..."
        }

        // Step 3: Parse prompt to understand user intent
        let intent = parsePromptIntent(config.prompt)

        // Step 4: Rank and select clips based on quality and intent
        let selectedClips = selectBestClips(
            from: allClips,
            intent: intent,
            maxDuration: config.maxDuration
        )

        guard !selectedClips.isEmpty else {
            throw HighlightReelError.noClipsSelected
        }

        await MainActor.run {
            generationProgress = 0.6
            currentStatus = "Creating highlight reel..."
        }

        // Step 5: Stitch clips together with transitions
        let outputURL = try await stitchClipsWithTransitions(
            clips: selectedClips,
            transitionStyle: config.transitionStyle
        )

        await MainActor.run {
            generationProgress = 0.95
            currentStatus = "Finalizing..."
        }

        // Calculate total duration
        let totalDuration = selectedClips.reduce(0) { $0 + $1.duration }

        // Get unique courses
        let coursesIncluded = Array(Set(selectedClips.compactMap { $0.course }))

        return HighlightReelResult(
            outputURL: outputURL,
            clipCount: selectedClips.count,
            totalDuration: totalDuration,
            coursesIncluded: coursesIncluded
        )
    }

    // MARK: - Video Filtering

    private func filterVideosByCourse(_ videos: [Video], courses: [String]) -> [Video] {
        // For now, include all videos as we don't have course metadata
        // In a full implementation, videos would have course tags
        return videos
    }

    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.date(from: dateString)
    }

    // MARK: - Clip Extraction

    private func extractClipsFromVideo(at videoPath: String, videoDate: Date?) async -> [HighlightClip] {
        let videoURL = URL(fileURLWithPath: videoPath)
        guard FileManager.default.fileExists(atPath: videoPath) else {
            return []
        }

        var clips: [HighlightClip] = []
        let asset = AVURLAsset(url: videoURL)

        do {
            let duration: CMTime
            if #available(iOS 16.0, *) {
                duration = try await asset.load(.duration)
            } else {
                duration = asset.duration
            }

            let durationSeconds = CMTimeGetSeconds(duration)

            // Sample the video to find swing sequences
            let swingSequences = await findSwingSequences(in: videoURL, totalDuration: durationSeconds)

            for sequence in swingSequences {
                // Add buffer around the swing
                let clipStart = max(0, sequence.startTime - 1.0)  // 1 second before
                let clipEnd = min(durationSeconds, sequence.endTime + 2.0)  // 2 seconds after

                let clip = HighlightClip(
                    sourceVideoPath: videoPath,
                    startTime: clipStart,
                    endTime: clipEnd,
                    qualityScore: sequence.qualityScore,
                    course: nil,  // Could be extracted from video metadata
                    date: videoDate
                )
                clips.append(clip)
            }

            // If no swings detected, create clips from the video in segments
            if clips.isEmpty && durationSeconds > 3 {
                // Create evenly-spaced clips
                let clipDuration: TimeInterval = 5.0
                var currentTime: TimeInterval = 0

                while currentTime + clipDuration <= durationSeconds {
                    let qualityScore = await swingAnalyzer.getClipQualityScore(at: videoPath)

                    let clip = HighlightClip(
                        sourceVideoPath: videoPath,
                        startTime: currentTime,
                        endTime: min(currentTime + clipDuration, durationSeconds),
                        qualityScore: qualityScore,
                        course: nil,
                        date: videoDate
                    )
                    clips.append(clip)
                    currentTime += clipDuration
                }
            }
        } catch {
            print("Error extracting clips: \(error)")
        }

        return clips
    }

    private struct SwingSequence {
        let startTime: TimeInterval
        let endTime: TimeInterval
        let qualityScore: Double
    }

    private func findSwingSequences(in videoURL: URL, totalDuration: TimeInterval) async -> [SwingSequence] {
        var sequences: [SwingSequence] = []
        let asset = AVURLAsset(url: videoURL)

        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero

        // Vision request for pose detection
        let poseRequest = VNDetectHumanBodyPoseRequest()

        // CoreML model for classification
        let config = MLModelConfiguration()
        config.computeUnits = .all
        guard let poseClassifier = try? GolfPoseClassifier(configuration: config).model else {
            return []
        }

        var currentSequence: (start: TimeInterval, hasReady: Bool, hasEndSwing: Bool)?
        var lastState = "others"
        var currentTime: TimeInterval = 0
        let sampleInterval: TimeInterval = 0.2  // Sample every 200ms

        while currentTime < totalDuration {
            let cmTime = CMTime(seconds: currentTime, preferredTimescale: 600)

            do {
                let cgImage = try await generator.image(at: cmTime).image
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

                do {
                    try handler.perform([poseRequest])

                    if let observation = poseRequest.results?.first {
                        let state = classifyPose(observation: observation, model: poseClassifier)

                        // State machine for finding swing sequences
                        if state == "ready" && lastState != "ready" {
                            // Start of a new potential swing
                            currentSequence = (start: currentTime, hasReady: true, hasEndSwing: false)
                        } else if state == "endswing" && currentSequence != nil {
                            // End of swing detected
                            currentSequence?.hasEndSwing = true
                        } else if state == "others" && currentSequence?.hasEndSwing == true {
                            // Swing completed, save the sequence
                            if let seq = currentSequence {
                                let qualityScore = (seq.hasReady && seq.hasEndSwing) ? 0.8 : 0.5
                                sequences.append(SwingSequence(
                                    startTime: seq.start,
                                    endTime: currentTime,
                                    qualityScore: qualityScore
                                ))
                            }
                            currentSequence = nil
                        }

                        lastState = state
                    }
                } catch {
                    print("Pose detection failed: \(error)")
                }
            } catch {
                print("Image generation failed at time \(currentTime): \(error)")
            }

            currentTime += sampleInterval
        }

        // Handle any unclosed sequence
        if let seq = currentSequence, seq.hasReady {
            sequences.append(SwingSequence(
                startTime: seq.start,
                endTime: min(seq.start + 6.0, totalDuration),  // Max 6 seconds per swing
                qualityScore: seq.hasEndSwing ? 0.7 : 0.4
            ))
        }

        return sequences
    }

    private func classifyPose(observation: VNHumanBodyPoseObservation, model: MLModel) -> String {
        // Extract features and classify (simplified version)
        // Returns "ready", "endswing", or "others"

        do {
            let features = extractFeatures(from: observation)
            let inputArray = try MLMultiArray(shape: [1, NSNumber(value: features.count)], dataType: .float32)

            for (index, value) in features.enumerated() {
                inputArray[index] = NSNumber(value: value)
            }

            let input = try MLDictionaryFeatureProvider(dictionary: ["features": inputArray])
            let prediction = try model.prediction(from: input)

            if let classLabel = prediction.featureValue(for: "classLabel")?.stringValue {
                return classLabel
            }
        } catch {
            print("Classification failed: \(error)")
        }

        return "others"
    }

    private func extractFeatures(from observation: VNHumanBodyPoseObservation) -> [Float] {
        var features: [Float] = Array(repeating: 0, count: 37)

        let jointNames: [VNHumanBodyPoseObservation.JointName] = [
            .nose, .neck,
            .leftShoulder, .rightShoulder,
            .leftElbow, .rightElbow,
            .leftWrist, .rightWrist,
            .leftHip, .rightHip,
            .leftKnee, .rightKnee,
            .leftAnkle, .rightAnkle
        ]

        // Get pelvis center for normalization
        let leftHip = try? observation.recognizedPoint(.leftHip)
        let rightHip = try? observation.recognizedPoint(.rightHip)
        let pelvisX = ((leftHip?.x ?? 0.5) + (rightHip?.x ?? 0.5)) / 2
        let pelvisY = ((leftHip?.y ?? 0.5) + (rightHip?.y ?? 0.5)) / 2

        var idx = 0
        for jointName in jointNames {
            if let point = try? observation.recognizedPoint(jointName), point.confidence > 0.1 {
                features[idx] = Float(point.x - pelvisX)
                features[idx + 1] = Float(point.y - pelvisY)
            }
            idx += 2
        }

        // Pad remaining features with zeros (angles, etc.)
        return features
    }

    // MARK: - Prompt Parsing

    private struct PromptIntent {
        var preferShortGame: Bool = false
        var preferDriving: Bool = false
        var preferPutting: Bool = false
        var maxClipCount: Int = 12
        var targetDuration: TimeInterval = 120  // 2 minutes default
    }

    private func parsePromptIntent(_ prompt: String) -> PromptIntent {
        var intent = PromptIntent()
        let lowercased = prompt.lowercased()

        // Check for shot type preferences
        if lowercased.contains("short game") || lowercased.contains("chip") || lowercased.contains("pitch") {
            intent.preferShortGame = true
        }
        if lowercased.contains("driv") || lowercased.contains("tee") || lowercased.contains("long") {
            intent.preferDriving = true
        }
        if lowercased.contains("putt") {
            intent.preferPutting = true
        }

        // Check for duration hints
        if lowercased.contains("1 minute") || lowercased.contains("1-minute") || lowercased.contains("short") {
            intent.targetDuration = 60
            intent.maxClipCount = 6
        } else if lowercased.contains("3 minute") || lowercased.contains("3-minute") || lowercased.contains("long") {
            intent.targetDuration = 180
            intent.maxClipCount = 18
        }

        // Check for clip count hints
        if let range = lowercased.range(of: "\\d+ (shot|clip|swing)", options: .regularExpression) {
            let match = String(lowercased[range])
            if let num = Int(match.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                intent.maxClipCount = min(num, 20)
            }
        }

        return intent
    }

    // MARK: - Clip Selection

    private func selectBestClips(
        from clips: [HighlightClip],
        intent: PromptIntent,
        maxDuration: TimeInterval
    ) -> [HighlightClip] {
        // Sort clips by quality score (highest first)
        let rankedClips = clips.sorted { $0.qualityScore > $1.qualityScore }

        // Select clips up to the target duration or max count
        var selectedClips: [HighlightClip] = []
        var totalDuration: TimeInterval = 0

        for clip in rankedClips {
            if selectedClips.count >= intent.maxClipCount {
                break
            }
            if totalDuration + clip.duration > maxDuration {
                continue  // Skip clips that would exceed duration
            }

            selectedClips.append(clip)
            totalDuration += clip.duration
        }

        // Sort selected clips chronologically by date
        selectedClips.sort { (clip1, clip2) in
            if let date1 = clip1.date, let date2 = clip2.date {
                return date1 < date2
            }
            return clip1.startTime < clip2.startTime
        }

        return selectedClips
    }

    // MARK: - Video Stitching

    private func stitchClipsWithTransitions(
        clips: [HighlightClip],
        transitionStyle: TransitionStyle
    ) async throws -> URL {
        // First, extract each clip as a separate video file
        var clipURLs: [URL] = []

        for (index, clip) in clips.enumerated() {
            if let extractedURL = try await extractClipAsFile(clip: clip, index: index) {
                clipURLs.append(extractedURL)
            }

            let progress = 0.6 + (Double(index + 1) / Double(clips.count)) * 0.3
            await MainActor.run {
                generationProgress = progress
            }
        }

        guard !clipURLs.isEmpty else {
            throw HighlightReelError.exportFailed
        }

        // Stitch all clips together
        let outputURL = try await stitchClips(clipURLs: clipURLs, transitionStyle: transitionStyle)

        // Clean up temp clips
        for url in clipURLs {
            try? FileManager.default.removeItem(at: url)
        }

        return outputURL
    }

    private func extractClipAsFile(clip: HighlightClip, index: Int) async throws -> URL? {
        let sourceURL = URL(fileURLWithPath: clip.sourceVideoPath)
        let asset = AVURLAsset(url: sourceURL)

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("clip-\(index)-\(UUID().uuidString).mp4")

        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            return nil
        }

        let startTime = CMTime(seconds: clip.startTime, preferredTimescale: 600)
        let endTime = CMTime(seconds: clip.endTime, preferredTimescale: 600)
        exportSession.timeRange = CMTimeRange(start: startTime, end: endTime)
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4

        if #available(iOS 18.0, *) {
            try await exportSession.export(to: outputURL, as: .mp4)
            return outputURL
        } else {
            await exportSession.export()
            
            switch exportSession.status {
            case .completed:
                return outputURL
            default:
                print("Clip export failed: \(exportSession.error?.localizedDescription ?? "unknown")")
                return nil
            }
        }
    }

    private func stitchClips(clipURLs: [URL], transitionStyle: TransitionStyle) async throws -> URL {
        guard !clipURLs.isEmpty else {
            throw HighlightReelError.exportFailed
        }

        let composition = AVMutableComposition()

        guard let videoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw HighlightReelError.exportFailed
        }

        var audioTrack: AVMutableCompositionTrack?
        var cursor = CMTime.zero
        var renderSize = CGSize(width: 1080, height: 1920)

        // Store transform configurations for each segment
        var layerConfigurations: [AVVideoCompositionLayerInstruction.Configuration] = []

        for (index, url) in clipURLs.enumerated() {
            let asset = AVURLAsset(url: url)

            do {
                let tracks = try await asset.load(.tracks)
                guard let sourceVideoTrack = tracks.first(where: { $0.mediaType == .video }) else { continue }

                let naturalSize = try await sourceVideoTrack.load(.naturalSize)
                let preferredTransform = try await sourceVideoTrack.load(.preferredTransform)
                let duration = try await asset.load(.duration)

                if index == 0 {
                    // Determine render size from first clip
                    let transformed = naturalSize.applying(preferredTransform)
                    renderSize = CGSize(width: abs(transformed.width), height: abs(transformed.height))
                }

                // Insert video segment
                let timeRange = CMTimeRange(start: .zero, duration: duration)
                try videoTrack.insertTimeRange(timeRange, of: sourceVideoTrack, at: cursor)

                // Insert audio if available
                if let sourceAudioTrack = tracks.first(where: { $0.mediaType == .audio }) {
                    if audioTrack == nil {
                        audioTrack = composition.addMutableTrack(
                            withMediaType: .audio,
                            preferredTrackID: kCMPersistentTrackID_Invalid
                        )
                    }
                    try audioTrack?.insertTimeRange(timeRange, of: sourceAudioTrack, at: cursor)
                }

                // Calculate the proper transform for this segment
                // We need to handle the source video's preferredTransform and normalize to our render size
                let transform = calculateNormalizedTransform(
                    preferredTransform: preferredTransform,
                    naturalSize: naturalSize,
                    renderSize: renderSize
                )

                // Create layer configuration for this segment
                var layerConfig = AVVideoCompositionLayerInstruction.Configuration(trackID: videoTrack.trackID)
                layerConfig.setTransform(transform, at: cursor)
                layerConfigurations.append(layerConfig)

                cursor = cursor + duration
            } catch {
                print("Error processing clip at \(url): \(error)")
                continue
            }
        }

        guard cursor > CMTime.zero else {
            throw HighlightReelError.exportFailed
        }

        // Build a single instruction that spans the full timeline
        var instructionConfig = AVVideoCompositionInstruction.Configuration(
            timeRange: CMTimeRange(start: .zero, duration: cursor)
        )
        instructionConfig.layerInstructions = layerConfigurations.map {
            AVVideoCompositionLayerInstruction(configuration: $0)
        }
        let instruction = AVVideoCompositionInstruction(configuration: instructionConfig)

        // Create video composition using the Configuration API
        var videoCompConfig = AVVideoComposition.Configuration()
        videoCompConfig.renderSize = renderSize
        videoCompConfig.frameDuration = CMTime(value: 1, timescale: 30)
        videoCompConfig.instructions = [instruction]

        // Add overlay layers (logo, badge)
        // Use a default scale suitable for video rendering (2x or 3x for high-quality output)
        let displayScale: CGFloat = 3.0
        addOverlaysToConfiguration(&videoCompConfig, renderSize: renderSize, displayScale: displayScale)

        let videoComposition = AVVideoComposition(configuration: videoCompConfig)

        // Export
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("highlight-reel-\(UUID().uuidString).mp4")

        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            throw HighlightReelError.exportFailed
        }

        exporter.videoComposition = videoComposition
        exporter.shouldOptimizeForNetworkUse = true

        if #available(iOS 18.0, *) {
            try await exporter.export(to: outputURL, as: .mp4)
            return outputURL
        } else {
            exporter.outputURL = outputURL
            exporter.outputFileType = .mp4
            await exporter.export()
            
            if exporter.status == .completed {
                return outputURL
            } else {
                print("Export failed: \(exporter.error?.localizedDescription ?? "unknown")")
                throw HighlightReelError.exportFailed
            }
        }
    }

    /// Calculates the proper transform to normalize a video segment to the target render size
    private func calculateNormalizedTransform(
        preferredTransform: CGAffineTransform,
        naturalSize: CGSize,
        renderSize: CGSize
    ) -> CGAffineTransform {
        // Apply the preferred transform to get the oriented size
        let orientedSize = naturalSize.applying(preferredTransform)
        let width = abs(orientedSize.width)
        let height = abs(orientedSize.height)

        // Start with the preferred transform
        var transform = preferredTransform

        // If the video was rotated, we need to adjust translations
        if transform.b == 1.0 && transform.c == -1.0 {
            // 90 degree rotation (portrait from landscape)
            transform.tx = height
            transform.ty = 0
        } else if transform.b == -1.0 && transform.c == 1.0 {
            // -90 degree rotation
            transform.tx = 0
            transform.ty = width
        } else if transform.a == -1.0 && transform.d == -1.0 {
            // 180 degree rotation
            transform.tx = width
            transform.ty = height
        }

        // Scale to fit render size if needed
        if width != renderSize.width || height != renderSize.height {
            let scaleX = renderSize.width / width
            let scaleY = renderSize.height / height
            let scale = min(scaleX, scaleY)  // Fit within bounds

            // Center the video
            let scaledWidth = width * scale
            let scaledHeight = height * scale
            let offsetX = (renderSize.width - scaledWidth) / 2
            let offsetY = (renderSize.height - scaledHeight) / 2

            transform = transform.scaledBy(x: scale, y: scale)
            transform = transform.translatedBy(x: offsetX / scale, y: offsetY / scale)
        }

        return transform
    }

    private func addOverlaysToConfiguration(_ config: inout AVVideoComposition.Configuration, renderSize: CGSize, displayScale: CGFloat) {
        let parentLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: renderSize)

        let videoLayer = CALayer()
        videoLayer.frame = parentLayer.frame
        parentLayer.addSublayer(videoLayer)

        // Add "Endless AI" badge at top-left
        let badgeLayer = CATextLayer()
        badgeLayer.contentsScale = displayScale
        badgeLayer.string = "ENDLESS AI"
        badgeLayer.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        badgeLayer.fontSize = 28
        badgeLayer.foregroundColor = UIColor.white.cgColor
        badgeLayer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
        badgeLayer.cornerRadius = 10
        badgeLayer.alignmentMode = .center
        badgeLayer.contentsGravity = .center

        let badgeWidth: CGFloat = 180
        let badgeHeight: CGFloat = 50
        let padding: CGFloat = 24
        badgeLayer.frame = CGRect(
            x: padding,
            y: renderSize.height - badgeHeight - padding,
            width: badgeWidth,
            height: badgeHeight
        )
        parentLayer.addSublayer(badgeLayer)

        // Add logo at bottom-right
        if let logoImage = UIImage(named: "AppLogoCircle")?.cgImage {
            let logoLayer = CALayer()
            logoLayer.contents = logoImage
            logoLayer.contentsGravity = .resizeAspect
            logoLayer.contentsScale = displayScale
            let logoSize: CGFloat = 100
            logoLayer.frame = CGRect(
                x: renderSize.width - logoSize - padding,
                y: padding,
                width: logoSize,
                height: logoSize
            )
            logoLayer.opacity = 0.9
            parentLayer.addSublayer(logoLayer)
        }

        config.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: parentLayer
        )
    }
}

// MARK: - Errors

enum HighlightReelError: Error, LocalizedError {
    case noVideosFound
    case noClipsExtracted
    case noClipsSelected
    case exportFailed

    var errorDescription: String? {
        switch self {
        case .noVideosFound:
            return "No videos found matching your criteria"
        case .noClipsExtracted:
            return "Could not extract clips from videos"
        case .noClipsSelected:
            return "No suitable clips found for highlight reel"
        case .exportFailed:
            return "Failed to export highlight reel"
        }
    }
}
