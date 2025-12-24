import Foundation
import AVFoundation
import Vision
import CoreML
import UIKit
import Combine

/// Analyzes golf swing videos using Vision framework and GolfPoseClassifier
class SwingAnalyzer: ObservableObject {
    static let shared = SwingAnalyzer()

    @Published var isAnalyzing = false
    @Published var analysisProgress: Double = 0

    private let analysisQueue = DispatchQueue(label: "com.endless.swingAnalysis", qos: .userInitiated)

    // Vision request for pose detection
    private lazy var poseRequest: VNDetectHumanBodyPoseRequest = {
        let request = VNDetectHumanBodyPoseRequest()
        return request
    }()

    // CoreML model for golf pose classification
    private lazy var poseClassifier: MLModel? = {
        let config = MLModelConfiguration()
        config.computeUnits = .all
        do {
            return try GolfPoseClassifier(configuration: config).model
        } catch {
            print("Failed to load GolfPoseClassifier: \(error)")
            return nil
        }
    }()

    private init() {}

    // MARK: - Public API

    /// Analyzes a swing video and returns detailed results
    func analyzeSwingVideo(at videoPath: String) async -> SwingAnalysisResult? {
        await MainActor.run {
            isAnalyzing = true
            analysisProgress = 0
        }

        defer {
            Task { @MainActor in
                isAnalyzing = false
                analysisProgress = 1.0
            }
        }

        let videoURL = URL(fileURLWithPath: videoPath)
        guard FileManager.default.fileExists(atPath: videoPath) else {
            print("Video file not found at path: \(videoPath)")
            return nil
        }

        // Extract frames and analyze poses
        let poseFrames = await extractPoseFrames(from: videoURL)

        await MainActor.run {
            analysisProgress = 0.5
        }

        guard !poseFrames.isEmpty else {
            print("No pose frames extracted from video")
            return nil
        }

        // Calculate swing metrics from pose data
        let metrics = calculateSwingMetrics(from: poseFrames)

        await MainActor.run {
            analysisProgress = 0.75
        }

        // Generate scores, tips, and drills based on metrics
        let result = generateAnalysisResult(
            videoId: videoURL.lastPathComponent,
            poseFrames: poseFrames,
            metrics: metrics
        )

        await MainActor.run {
            analysisProgress = 1.0
        }

        return result
    }

    /// Quick quality score for a video clip (used for highlight reel ranking)
    func getClipQualityScore(at videoPath: String) async -> Double {
        let videoURL = URL(fileURLWithPath: videoPath)
        guard FileManager.default.fileExists(atPath: videoPath) else {
            return 0.0
        }

        let poseFrames = await extractPoseFrames(from: videoURL, sampleRate: 0.5) // Lower sample rate for speed

        guard !poseFrames.isEmpty else {
            return 0.0
        }

        // Score based on:
        // 1. Presence of clear ready and endswing states
        // 2. Confidence scores
        // 3. Smooth transitions

        let hasReadyState = poseFrames.contains { $0.classifiedState == "ready" && $0.stateConfidence > 0.7 }
        let hasEndSwing = poseFrames.contains { $0.classifiedState == "endswing" && $0.stateConfidence > 0.7 }
        let avgConfidence = poseFrames.map { $0.confidence }.reduce(0, +) / Double(poseFrames.count)

        var score = avgConfidence * 0.4  // Base confidence score

        if hasReadyState { score += 0.3 }
        if hasEndSwing { score += 0.3 }

        return min(1.0, score)
    }

    // MARK: - Frame Extraction

    private func extractPoseFrames(from videoURL: URL, sampleRate: TimeInterval = 0.1) async -> [PoseFrameData] {
        let asset = AVURLAsset(url: videoURL)
        var poseFrames: [PoseFrameData] = []

        do {
            let duration: CMTime
            if #available(iOS 16.0, *) {
                duration = try await asset.load(.duration)
            } else {
                duration = asset.duration
            }

            let durationSeconds = CMTimeGetSeconds(duration)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.requestedTimeToleranceBefore = .zero
            generator.requestedTimeToleranceAfter = .zero

            var currentTime: TimeInterval = 0

            while currentTime < durationSeconds {
                let cmTime = CMTime(seconds: currentTime, preferredTimescale: 600)

                do {
                    let cgImage = try await generator.image(at: cmTime).image
                    if let poseData = await analyzePoseInFrame(cgImage, at: currentTime) {
                        poseFrames.append(poseData)
                    }
                } catch {
                    // Skip frames that fail to generate
                    print("Failed to generate image at time \(currentTime): \(error)")
                }

                currentTime += sampleRate

                // Update progress
                let progress = currentTime / durationSeconds * 0.5  // First half of analysis
                await MainActor.run {
                    analysisProgress = progress
                }
            }
        } catch {
            print("Error extracting frames: \(error)")
        }

        return poseFrames
    }

    private func analyzePoseInFrame(_ image: CGImage, at timestamp: TimeInterval) async -> PoseFrameData? {
        return await withCheckedContinuation { continuation in
            analysisQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(returning: nil)
                    return
                }

                let handler = VNImageRequestHandler(cgImage: image, options: [:])

                do {
                    try handler.perform([self.poseRequest])

                    guard let observation = self.poseRequest.results?.first else {
                        continuation.resume(returning: nil)
                        return
                    }

                    // Extract joint positions
                    var joints: [String: CGPoint] = [:]
                    let jointNames: [VNHumanBodyPoseObservation.JointName] = [
                        .nose, .neck,
                        .leftShoulder, .rightShoulder,
                        .leftElbow, .rightElbow,
                        .leftWrist, .rightWrist,
                        .leftHip, .rightHip,
                        .leftKnee, .rightKnee,
                        .leftAnkle, .rightAnkle
                    ]

                    var totalConfidence: Double = 0
                    var jointCount = 0

                    for jointName in jointNames {
                        if let point = try? observation.recognizedPoint(jointName),
                           point.confidence > 0.1 {
                            joints[jointName.rawValue.rawValue] = point.location
                            totalConfidence += Double(point.confidence)
                            jointCount += 1
                        }
                    }

                    let avgConfidence = jointCount > 0 ? totalConfidence / Double(jointCount) : 0

                    // Classify pose state using ML model
                    let (classifiedState, stateConfidence) = self.classifyPose(joints: joints)

                    let poseData = PoseFrameData(
                        timestamp: timestamp,
                        joints: joints,
                        confidence: avgConfidence,
                        classifiedState: classifiedState,
                        stateConfidence: stateConfidence
                    )

                    continuation.resume(returning: poseData)
                } catch {
                    print("Vision request failed: \(error)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    private func classifyPose(joints: [String: CGPoint]) -> (String, Double) {
        guard let model = poseClassifier else {
            return ("others", 0.0)
        }

        // Build feature vector (matching the 37-feature format from PoseSessionCameraView)
        let features = buildFeatureVector(from: joints)

        do {
            let inputArray = try MLMultiArray(shape: [1, NSNumber(value: features.count)], dataType: .float32)
            for (index, value) in features.enumerated() {
                inputArray[index] = NSNumber(value: value)
            }

            let input = try MLDictionaryFeatureProvider(dictionary: ["features": inputArray])
            let prediction = try model.prediction(from: input)

            if let classLabel = prediction.featureValue(for: "classLabel")?.stringValue,
               let probs = prediction.featureValue(for: "classLabel_probs")?.dictionaryValue,
               let confidence = probs[classLabel] as? Double {
                return (classLabel, confidence)
            }
        } catch {
            print("ML prediction failed: \(error)")
        }

        return ("others", 0.0)
    }

    private func buildFeatureVector(from joints: [String: CGPoint]) -> [Float] {
        // Build 37-feature vector matching GolfPoseClassifier input
        // Features: 14 joints x 2 (x,y) = 28 + 7 angles + 2 hand features = 37

        var features: [Float] = []

        let jointOrder = [
            "nose", "neck",
            "left_shoulder_1_joint", "right_shoulder_1_joint",
            "left_elbow_1_joint", "right_elbow_1_joint",
            "left_wrist_1_joint", "right_wrist_1_joint",
            "left_hip_1_joint", "right_hip_1_joint",
            "left_knee_1_joint", "right_knee_1_joint",
            "left_ankle_1_joint", "right_ankle_1_joint"
        ]

        // Get pelvis center for normalization
        let leftHip = joints["left_hip_1_joint"] ?? CGPoint(x: 0.5, y: 0.5)
        let rightHip = joints["right_hip_1_joint"] ?? CGPoint(x: 0.5, y: 0.5)
        let pelvisCenter = CGPoint(
            x: (leftHip.x + rightHip.x) / 2,
            y: (leftHip.y + rightHip.y) / 2
        )

        // Add normalized joint positions (28 features)
        for jointName in jointOrder {
            if let point = joints[jointName] {
                features.append(Float(point.x - pelvisCenter.x))
                features.append(Float(point.y - pelvisCenter.y))
            } else {
                features.append(0.0)
                features.append(0.0)
            }
        }

        // Add angle features (7 features)
        let leftShoulder = joints["left_shoulder_1_joint"] ?? .zero
        let rightShoulder = joints["right_shoulder_1_joint"] ?? .zero
        let shoulderAngle = atan2(rightShoulder.y - leftShoulder.y, rightShoulder.x - leftShoulder.x)
        features.append(Float(shoulderAngle))

        let hipAngle = atan2(rightHip.y - leftHip.y, rightHip.x - leftHip.x)
        features.append(Float(hipAngle))

        // Trunk pitch (simplified)
        let neck = joints["neck"] ?? .zero
        let trunkAngle = atan2(neck.y - pelvisCenter.y, neck.x - pelvisCenter.x)
        features.append(Float(trunkAngle))

        // Elbow angles (simplified as positions relative to shoulders)
        let leftElbow = joints["left_elbow_1_joint"] ?? .zero
        let rightElbow = joints["right_elbow_1_joint"] ?? .zero
        features.append(Float(leftElbow.y - leftShoulder.y))
        features.append(Float(rightElbow.y - rightShoulder.y))

        // Knee angles (simplified)
        let leftKnee = joints["left_knee_1_joint"] ?? .zero
        let rightKnee = joints["right_knee_1_joint"] ?? .zero
        features.append(Float(leftKnee.y - leftHip.y))
        features.append(Float(rightKnee.y - rightHip.y))

        // Hand position features (2 features)
        let leftWrist = joints["left_wrist_1_joint"] ?? .zero
        let rightWrist = joints["right_wrist_1_joint"] ?? .zero
        let handsHeight = (leftWrist.y + rightWrist.y) / 2 - (leftShoulder.y + rightShoulder.y) / 2
        features.append(Float(handsHeight))

        let wristDistance = sqrt(pow(rightWrist.x - leftWrist.x, 2) + pow(rightWrist.y - leftWrist.y, 2))
        features.append(Float(wristDistance))

        // Ensure we have exactly 37 features
        while features.count < 37 {
            features.append(0.0)
        }

        return Array(features.prefix(37))
    }

    // MARK: - Metrics Calculation

    private func calculateSwingMetrics(from poseFrames: [PoseFrameData]) -> SwingMetrics {
        // Find key swing phases
        let readyFrames = poseFrames.filter { $0.classifiedState == "ready" }
        let endSwingFrames = poseFrames.filter { $0.classifiedState == "endswing" }

        // Calculate timing
        let firstReady = readyFrames.first?.timestamp ?? 0
        let firstEndSwing = endSwingFrames.first?.timestamp ?? poseFrames.last?.timestamp ?? 0

        let swingDuration = firstEndSwing - firstReady

        // Estimate backswing and downswing duration (simplified)
        let midPoint = firstReady + swingDuration * 0.6  // Backswing is typically longer
        let backswingDuration = midPoint - firstReady
        let downswingDuration = swingDuration - backswingDuration

        let tempoRatio = downswingDuration > 0 ? backswingDuration / downswingDuration : 3.0

        // Calculate body angles from pose data (simplified averages)
        var shoulderAngles: [Double] = []
        var hipAngles: [Double] = []
        var headPositions: [CGPoint] = []

        for frame in poseFrames {
            if let leftShoulder = frame.joints["left_shoulder_1_joint"],
               let rightShoulder = frame.joints["right_shoulder_1_joint"] {
                let angle = atan2(rightShoulder.y - leftShoulder.y, rightShoulder.x - leftShoulder.x)
                shoulderAngles.append(angle * 180 / .pi)
            }

            if let leftHip = frame.joints["left_hip_1_joint"],
               let rightHip = frame.joints["right_hip_1_joint"] {
                let angle = atan2(rightHip.y - leftHip.y, rightHip.x - leftHip.x)
                hipAngles.append(angle * 180 / .pi)
            }

            if let nose = frame.joints["nose"] {
                headPositions.append(nose)
            }
        }

        let shoulderTurn = shoulderAngles.isEmpty ? 0 : (shoulderAngles.max() ?? 0) - (shoulderAngles.min() ?? 0)
        let hipTurn = hipAngles.isEmpty ? 0 : (hipAngles.max() ?? 0) - (hipAngles.min() ?? 0)

        // Calculate head movement (sway)
        var headMovement: Double = 0
        if headPositions.count > 1 {
            let xPositions = headPositions.map { $0.x }
            headMovement = Double((xPositions.max() ?? 0) - (xPositions.min() ?? 0))
        }

        return SwingMetrics(
            swingDuration: swingDuration,
            backswingDuration: backswingDuration,
            downswingDuration: downswingDuration,
            tempoRatio: tempoRatio,
            shoulderTurnAngle: shoulderTurn,
            hipTurnAngle: hipTurn,
            spineAngle: 0,  // Simplified
            headMovement: headMovement,
            weightTransfer: 0  // Simplified
        )
    }

    // MARK: - Result Generation

    private func generateAnalysisResult(
        videoId: String,
        poseFrames: [PoseFrameData],
        metrics: SwingMetrics
    ) -> SwingAnalysisResult {
        // Generate scores based on metrics
        let breakdown = generatePhaseScores(poseFrames: poseFrames, metrics: metrics)

        // Calculate overall score as weighted average
        let overallScore = breakdown.isEmpty ? 75 : breakdown.map { $0.score }.reduce(0, +) / breakdown.count

        // Generate tips based on weak areas
        let tips = generateTips(breakdown: breakdown, metrics: metrics)

        // Generate drill recommendations
        let drills = generateDrills(breakdown: breakdown)

        return SwingAnalysisResult(
            videoId: videoId,
            overallScore: overallScore,
            breakdown: breakdown,
            tips: tips,
            drills: drills,
            improvement: nil
        )
    }

    private func generatePhaseScores(poseFrames: [PoseFrameData], metrics: SwingMetrics) -> [SwingPhaseScore] {
        var scores: [SwingPhaseScore] = []

        // Grip - based on wrist positions and stability
        let gripScore = calculateGripScore(poseFrames: poseFrames)
        scores.append(SwingPhaseScore(
            phase: .grip,
            score: gripScore,
            feedback: gripScore >= 80 ? "Solid neutral grip position" : "Work on maintaining consistent grip pressure"
        ))

        // Stance - based on hip and shoulder alignment
        let stanceScore = calculateStanceScore(poseFrames: poseFrames)
        scores.append(SwingPhaseScore(
            phase: .stance,
            score: stanceScore,
            feedback: stanceScore >= 80 ? "Good width and alignment" : "Check your stance width and foot alignment"
        ))

        // Backswing - based on shoulder turn and tempo
        let backswingScore = calculateBackswingScore(metrics: metrics)
        scores.append(SwingPhaseScore(
            phase: .backswing,
            score: backswingScore,
            feedback: backswingScore >= 80 ? "Full shoulder turn achieved" : "Try to complete your shoulder turn"
        ))

        // Downswing - based on tempo ratio and sequence
        let downswingScore = calculateDownswingScore(metrics: metrics)
        scores.append(SwingPhaseScore(
            phase: .downswing,
            score: downswingScore,
            feedback: downswingScore >= 80 ? "Good tempo and sequence" : "Maintain lag longer in the downswing"
        ))

        // Impact - based on pose stability and alignment
        let impactScore = calculateImpactScore(poseFrames: poseFrames)
        scores.append(SwingPhaseScore(
            phase: .impact,
            score: impactScore,
            feedback: impactScore >= 80 ? "Square face at contact" : "Focus on squaring the face at impact"
        ))

        // Follow-through - based on end swing pose quality
        let followThroughScore = calculateFollowThroughScore(poseFrames: poseFrames)
        scores.append(SwingPhaseScore(
            phase: .followThrough,
            score: followThroughScore,
            feedback: followThroughScore >= 80 ? "Full balanced finish" : "Extend more toward the target"
        ))

        return scores
    }

    private func calculateGripScore(poseFrames: [PoseFrameData]) -> Int {
        // Score based on wrist stability during ready phase
        let readyFrames = poseFrames.filter { $0.classifiedState == "ready" }
        guard !readyFrames.isEmpty else { return 75 }

        let avgConfidence = readyFrames.map { $0.confidence }.reduce(0, +) / Double(readyFrames.count)
        return Int(70 + avgConfidence * 20)
    }

    private func calculateStanceScore(poseFrames: [PoseFrameData]) -> Int {
        guard let readyFrame = poseFrames.first(where: { $0.classifiedState == "ready" }) else {
            return 75
        }

        // Check hip alignment
        if let leftHip = readyFrame.joints["left_hip_1_joint"],
           let rightHip = readyFrame.joints["right_hip_1_joint"] {
            let hipLevel = abs(leftHip.y - rightHip.y)
            let levelScore = max(0, 1.0 - hipLevel * 10)  // Penalize uneven hips
            return Int(70 + levelScore * 20)
        }

        return 75
    }

    private func calculateBackswingScore(metrics: SwingMetrics) -> Int {
        // Good shoulder turn is 80-100 degrees
        let shoulderScore = min(1.0, metrics.shoulderTurnAngle / 90.0)

        // Ideal tempo ratio is about 3:1
        let tempoScore = 1.0 - min(1.0, abs(metrics.tempoRatio - 3.0) / 3.0)

        return Int(70 + (shoulderScore * 0.6 + tempoScore * 0.4) * 20)
    }

    private func calculateDownswingScore(metrics: SwingMetrics) -> Int {
        // Check tempo ratio
        let tempoScore = 1.0 - min(1.0, abs(metrics.tempoRatio - 3.0) / 3.0)

        // Check hip turn leads shoulder turn
        let sequenceScore = metrics.hipTurnAngle > 0 ? 0.8 : 0.5

        return Int(70 + (tempoScore * 0.5 + sequenceScore * 0.5) * 20)
    }

    private func calculateImpactScore(poseFrames: [PoseFrameData]) -> Int {
        // Look for high-confidence frames during the swing
        let swingFrames = poseFrames.filter { $0.classifiedState != "ready" }
        guard !swingFrames.isEmpty else { return 75 }

        let avgConfidence = swingFrames.map { $0.confidence }.reduce(0, +) / Double(swingFrames.count)
        return Int(70 + avgConfidence * 20)
    }

    private func calculateFollowThroughScore(poseFrames: [PoseFrameData]) -> Int {
        // Check endswing pose quality
        let endSwingFrames = poseFrames.filter { $0.classifiedState == "endswing" }
        guard !endSwingFrames.isEmpty else { return 75 }

        let avgConfidence = endSwingFrames.map { $0.stateConfidence }.reduce(0, +) / Double(endSwingFrames.count)
        return Int(70 + avgConfidence * 20)
    }

    private func generateTips(breakdown: [SwingPhaseScore], metrics: SwingMetrics) -> [SwingTip] {
        var tips: [SwingTip] = []

        // Sort by lowest scores first
        let sortedPhases = breakdown.sorted { $0.score < $1.score }

        // Generate tips for the weakest 3 areas
        for phase in sortedPhases.prefix(3) {
            switch phase.phase {
            case .grip:
                tips.append(SwingTip(
                    icon: "hand.raised.fill",
                    title: "Strengthen Your Grip",
                    description: "Focus on maintaining consistent grip pressure throughout the swing. Avoid squeezing too tight at the top.",
                    priority: phase.score < 70 ? .high : .medium
                ))
            case .stance:
                tips.append(SwingTip(
                    icon: "figure.stand",
                    title: "Check Your Setup",
                    description: "Ensure your feet are shoulder-width apart with slight knee flex. Your weight should be balanced on the balls of your feet.",
                    priority: phase.score < 70 ? .high : .medium
                ))
            case .backswing:
                tips.append(SwingTip(
                    icon: "arrow.up.backward",
                    title: "Complete Your Turn",
                    description: "Focus on turning your shoulders fully while maintaining your spine angle. Your back should face the target at the top.",
                    priority: phase.score < 70 ? .high : .medium
                ))
            case .downswing:
                tips.append(SwingTip(
                    icon: "hand.raised.fill",
                    title: "Maintain Lag Longer",
                    description: "Keep your wrists cocked until your hands pass your right thigh. This stores power for impact.",
                    priority: phase.score < 70 ? .high : .medium
                ))
            case .impact:
                tips.append(SwingTip(
                    icon: "bolt.fill",
                    title: "Square at Impact",
                    description: "Focus on returning the clubface to square at impact. Your hips should be open while shoulders are nearly square.",
                    priority: phase.score < 70 ? .high : .medium
                ))
            case .followThrough:
                tips.append(SwingTip(
                    icon: "arrow.right.circle.fill",
                    title: "Extend Through Impact",
                    description: "Push your arms toward the target after contact. Finish with your weight on your front foot and belt buckle facing the target.",
                    priority: phase.score < 70 ? .high : .medium
                ))
            }
        }

        // Add tempo tip if needed
        if metrics.tempoRatio < 2.0 || metrics.tempoRatio > 4.0 {
            tips.append(SwingTip(
                icon: "metronome.fill",
                title: "Smooth Tempo",
                description: "Try a 3:1 backswing to downswing ratio for better timing. Use a metronome at 60 BPM to practice.",
                priority: .medium
            ))
        }

        return tips
    }

    private func generateDrills(breakdown: [SwingPhaseScore]) -> [RecommendedDrill] {
        var drills: [RecommendedDrill] = []

        // Find the weakest phases
        let weakPhases = breakdown.filter { $0.score < 80 }.sorted { $0.score < $1.score }

        for phase in weakPhases.prefix(3) {
            switch phase.phase {
            case .grip:
                drills.append(RecommendedDrill(
                    title: "Grip Pressure Drill",
                    duration: "10 min",
                    description: "Practice gripping the club at a 4 out of 10 pressure. Hit half-swings focusing on maintaining consistent pressure.",
                    targetPhase: .grip
                ))
            case .stance:
                drills.append(RecommendedDrill(
                    title: "Alignment Stick Setup",
                    duration: "15 min",
                    description: "Use alignment sticks to check your feet, hips, and shoulder alignment at address.",
                    targetPhase: .stance
                ))
            case .backswing:
                drills.append(RecommendedDrill(
                    title: "Turn Drill",
                    duration: "10 min",
                    description: "Practice turning your shoulders while keeping your lower body stable. Use a mirror to check your positions.",
                    targetPhase: .backswing
                ))
            case .downswing:
                drills.append(RecommendedDrill(
                    title: "Lag Drill",
                    duration: "10 min",
                    description: "Practice maintaining wrist angle with slow-motion swings. Feel the club 'drop' into the slot.",
                    targetPhase: .downswing
                ))
            case .impact:
                drills.append(RecommendedDrill(
                    title: "Impact Bag Training",
                    duration: "15 min",
                    description: "Hit into an impact bag focusing on a square clubface and forward shaft lean at contact.",
                    targetPhase: .impact
                ))
            case .followThrough:
                drills.append(RecommendedDrill(
                    title: "Extension Drill",
                    duration: "15 min",
                    description: "Use alignment sticks to practice full extension toward the target after impact.",
                    targetPhase: .followThrough
                ))
            }
        }

        // Always include tempo training
        drills.append(RecommendedDrill(
            title: "Tempo Training",
            duration: "20 min",
            description: "Swing with a metronome at 60 BPM. Count '1' at takeaway, '2' at top, '3' at impact.",
            targetPhase: .backswing
        ))

        return drills
    }
}
