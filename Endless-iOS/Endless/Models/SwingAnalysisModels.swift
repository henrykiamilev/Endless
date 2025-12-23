import Foundation

// MARK: - Swing Analysis Result

/// Complete analysis result for a swing video
struct SwingAnalysisResult: Codable, Identifiable {
    let id: String
    let videoId: String
    let analyzedAt: Date
    let overallScore: Int  // 0-100
    let breakdown: [SwingPhaseScore]
    let tips: [SwingTip]
    let drills: [RecommendedDrill]
    let improvement: Int?  // Change from last analysis (e.g., +5)

    init(id: String = UUID().uuidString,
         videoId: String,
         analyzedAt: Date = Date(),
         overallScore: Int,
         breakdown: [SwingPhaseScore],
         tips: [SwingTip],
         drills: [RecommendedDrill],
         improvement: Int? = nil) {
        self.id = id
        self.videoId = videoId
        self.analyzedAt = analyzedAt
        self.overallScore = overallScore
        self.breakdown = breakdown
        self.tips = tips
        self.drills = drills
        self.improvement = improvement
    }
}

// MARK: - Swing Phase Score

/// Score for a specific phase of the swing
struct SwingPhaseScore: Codable, Identifiable {
    let id: String
    let phase: SwingPhase
    let score: Int  // 0-100
    let feedback: String

    init(id: String = UUID().uuidString, phase: SwingPhase, score: Int, feedback: String) {
        self.id = id
        self.phase = phase
        self.score = score
        self.feedback = feedback
    }
}

/// Phases of a golf swing
enum SwingPhase: String, Codable, CaseIterable {
    case grip = "Grip"
    case stance = "Stance"
    case backswing = "Backswing"
    case downswing = "Downswing"
    case impact = "Impact"
    case followThrough = "Follow-through"

    var icon: String {
        switch self {
        case .grip: return "hand.raised.fill"
        case .stance: return "figure.stand"
        case .backswing: return "arrow.up.backward"
        case .downswing: return "arrow.down.forward"
        case .impact: return "bolt.fill"
        case .followThrough: return "arrow.right"
        }
    }
}

// MARK: - Swing Tip

/// A tip for improving the swing
struct SwingTip: Codable, Identifiable {
    let id: String
    let icon: String
    let title: String
    let description: String
    let priority: TipPriority

    init(id: String = UUID().uuidString, icon: String, title: String, description: String, priority: TipPriority = .medium) {
        self.id = id
        self.icon = icon
        self.title = title
        self.description = description
        self.priority = priority
    }
}

enum TipPriority: String, Codable {
    case high
    case medium
    case low
}

// MARK: - Recommended Drill

/// A drill recommended based on swing analysis
struct RecommendedDrill: Codable, Identifiable {
    let id: String
    let title: String
    let duration: String
    let description: String
    let targetPhase: SwingPhase

    init(id: String = UUID().uuidString, title: String, duration: String, description: String, targetPhase: SwingPhase) {
        self.id = id
        self.title = title
        self.duration = duration
        self.description = description
        self.targetPhase = targetPhase
    }
}

// MARK: - Swing Video Types

/// Type of swing video angle
enum SwingVideoType: String, Codable, CaseIterable {
    case downTheLine = "DTL"
    case faceOn = "Face On"
    case behindView = "Behind"
    case frontView = "Front"

    var displayName: String {
        switch self {
        case .downTheLine: return "Down the Line"
        case .faceOn: return "Face On"
        case .behindView: return "Behind View"
        case .frontView: return "Front View"
        }
    }
}

// MARK: - Managed Swing Video

/// A swing video managed for AI analysis (up to 5 allowed)
struct ManagedSwingVideo: Identifiable, Codable {
    let id: String
    let videoPath: String
    let type: SwingVideoType
    let annotation: String
    let createdAt: Date
    var analysisResult: SwingAnalysisResult?

    init(id: String = UUID().uuidString,
         videoPath: String,
         type: SwingVideoType,
         annotation: String,
         createdAt: Date = Date(),
         analysisResult: SwingAnalysisResult? = nil) {
        self.id = id
        self.videoPath = videoPath
        self.type = type
        self.annotation = annotation
        self.createdAt = createdAt
        self.analysisResult = analysisResult
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return "\(type.rawValue) - \(formatter.string(from: createdAt))"
    }
}

// MARK: - Highlight Reel Configuration

/// Configuration for generating a highlight reel
struct HighlightReelConfig {
    let prompt: String
    let selectedCourses: [String]
    let maxDuration: TimeInterval  // in seconds
    let includeTransitions: Bool
    let transitionStyle: TransitionStyle

    init(prompt: String,
         selectedCourses: [String] = [],
         maxDuration: TimeInterval = 120,  // 2 minutes default
         includeTransitions: Bool = true,
         transitionStyle: TransitionStyle = .crossDissolve) {
        self.prompt = prompt
        self.selectedCourses = selectedCourses
        self.maxDuration = maxDuration
        self.includeTransitions = includeTransitions
        self.transitionStyle = transitionStyle
    }
}

enum TransitionStyle: String, Codable {
    case crossDissolve = "Cross Dissolve"
    case fade = "Fade"
    case wipe = "Wipe"
    case none = "None"
}

// MARK: - Video Clip for Highlight Reel

/// A clip selected for inclusion in a highlight reel
struct HighlightClip: Identifiable {
    let id: String
    let sourceVideoPath: String
    let startTime: TimeInterval
    let endTime: TimeInterval
    let qualityScore: Double  // 0-1, used for ranking
    let course: String?
    let date: Date?

    var duration: TimeInterval {
        endTime - startTime
    }

    init(id: String = UUID().uuidString,
         sourceVideoPath: String,
         startTime: TimeInterval,
         endTime: TimeInterval,
         qualityScore: Double,
         course: String? = nil,
         date: Date? = nil) {
        self.id = id
        self.sourceVideoPath = sourceVideoPath
        self.startTime = startTime
        self.endTime = endTime
        self.qualityScore = qualityScore
        self.course = course
        self.date = date
    }
}

// MARK: - Highlight Reel Result

/// Result of highlight reel generation
struct HighlightReelResult {
    let outputURL: URL
    let clipCount: Int
    let totalDuration: TimeInterval
    let coursesIncluded: [String]
    let generatedAt: Date

    init(outputURL: URL, clipCount: Int, totalDuration: TimeInterval, coursesIncluded: [String], generatedAt: Date = Date()) {
        self.outputURL = outputURL
        self.clipCount = clipCount
        self.totalDuration = totalDuration
        self.coursesIncluded = coursesIncluded
        self.generatedAt = generatedAt
    }
}

// MARK: - AI Coach Message

/// A message in the AI Coach chat
struct AICoachMessage: Identifiable, Codable {
    let id: String
    let isUser: Bool
    let text: String
    let timestamp: Date

    init(id: String = UUID().uuidString, isUser: Bool, text: String, timestamp: Date = Date()) {
        self.id = id
        self.isUser = isUser
        self.text = text
        self.timestamp = timestamp
    }
}

// MARK: - Pose Analysis Data

/// Raw pose data extracted from a video frame
struct PoseFrameData {
    let timestamp: TimeInterval
    let joints: [String: CGPoint]  // Joint name -> normalized position
    let confidence: Double
    let classifiedState: String  // "ready", "endswing", "others"
    let stateConfidence: Double
}

/// Aggregate pose metrics for a swing
struct SwingMetrics {
    let swingDuration: TimeInterval
    let backswingDuration: TimeInterval
    let downswingDuration: TimeInterval
    let tempoRatio: Double  // backswing:downswing ratio (ideal ~3:1)
    let shoulderTurnAngle: Double
    let hipTurnAngle: Double
    let spineAngle: Double
    let headMovement: Double  // Amount of head sway
    let weightTransfer: Double  // Lateral hip movement
}
