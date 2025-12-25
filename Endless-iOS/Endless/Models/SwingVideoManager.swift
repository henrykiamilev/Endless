import Foundation
import SwiftUI
import Combine

/// Manages swing videos for AI analysis (up to 5 videos per user)
class SwingVideoManager: ObservableObject {
    static let shared = SwingVideoManager()

    @Published private(set) var swingVideos: [ManagedSwingVideo] = []
    @Published var isLoading = false

    private let maxVideos = 5
    private var currentUserId: String?
    private let fileManager = FileManager.default

    private let baseDirectoryName = "SwingVideos"
    private let metadataFileName = "swing_videos_metadata.json"

    private var baseDirectory: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(baseDirectoryName)
    }

    private var userDirectory: URL {
        if let userId = currentUserId {
            return baseDirectory.appendingPathComponent(userId)
        }
        return baseDirectory.appendingPathComponent("anonymous")
    }

    private var metadataURL: URL {
        userDirectory.appendingPathComponent(metadataFileName)
    }

    var canAddMoreVideos: Bool {
        swingVideos.count < maxVideos
    }

    var videoCount: Int {
        swingVideos.count
    }

    private init() {
        // Load videos for anonymous user by default
        createDirectoryIfNeeded()
        loadSwingVideos()
    }

    // MARK: - User Context

    func setCurrentUser(userId: String) {
        guard currentUserId != userId else { return }
        currentUserId = userId
        createDirectoryIfNeeded()
        loadSwingVideos()
    }

    func clearCurrentUser() {
        currentUserId = nil
        swingVideos = []
    }

    private func createDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: userDirectory.path) {
            try? fileManager.createDirectory(at: userDirectory, withIntermediateDirectories: true)
        }
    }

    // MARK: - CRUD Operations

    /// Adds a new swing video for analysis
    /// - Parameters:
    ///   - sourceURL: The source URL of the video to copy
    ///   - type: The type of swing video (DTL, Face On, etc.)
    ///   - annotation: User's annotation/notes for the video
    ///   - completion: Called with the created video or nil if failed
    func addSwingVideo(
        from sourceURL: URL,
        type: SwingVideoType,
        annotation: String,
        completion: @escaping (ManagedSwingVideo?) -> Void
    ) {
        guard canAddMoreVideos else {
            print("Maximum swing videos reached (\(maxVideos))")
            completion(nil)
            return
        }

        isLoading = true

        let videoId = UUID().uuidString
        let fileName = "swing-\(videoId).mp4"
        let destinationURL = userDirectory.appendingPathComponent(fileName)

        do {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)

            let video = ManagedSwingVideo(
                id: videoId,
                videoPath: destinationURL.path,
                type: type,
                annotation: annotation
            )

            swingVideos.insert(video, at: 0)
            saveMetadata()

            isLoading = false
            completion(video)

            // Clean up source if it's a temp file
            if sourceURL.path.contains("tmp") {
                try? fileManager.removeItem(at: sourceURL)
            }
        } catch {
            print("Failed to add swing video: \(error)")
            isLoading = false
            completion(nil)
        }
    }

    /// Updates the annotation for a swing video
    func updateAnnotation(for videoId: String, annotation: String) {
        if let index = swingVideos.firstIndex(where: { $0.id == videoId }) {
            var video = swingVideos[index]
            video = ManagedSwingVideo(
                id: video.id,
                videoPath: video.videoPath,
                type: video.type,
                annotation: annotation,
                createdAt: video.createdAt,
                analysisResult: video.analysisResult
            )
            swingVideos[index] = video
            saveMetadata()
        }
    }

    /// Updates the analysis result for a swing video
    func updateAnalysisResult(for videoId: String, result: SwingAnalysisResult) {
        if let index = swingVideos.firstIndex(where: { $0.id == videoId }) {
            var video = swingVideos[index]
            video = ManagedSwingVideo(
                id: video.id,
                videoPath: video.videoPath,
                type: video.type,
                annotation: video.annotation,
                createdAt: video.createdAt,
                analysisResult: result
            )
            swingVideos[index] = video
            saveMetadata()
        }
    }

    /// Deletes a swing video
    func deleteSwingVideo(_ video: ManagedSwingVideo) {
        guard let index = swingVideos.firstIndex(where: { $0.id == video.id }) else { return }

        // Delete the video file
        try? fileManager.removeItem(atPath: video.videoPath)

        // Remove from array
        swingVideos.remove(at: index)
        saveMetadata()
    }

    /// Deletes a swing video by ID
    func deleteSwingVideo(id: String) {
        if let video = swingVideos.first(where: { $0.id == id }) {
            deleteSwingVideo(video)
        }
    }

    /// Analyzes a swing video and updates its analysis result
    func analyzeSwingVideo(_ video: ManagedSwingVideo) async -> SwingAnalysisResult? {
        await MainActor.run {
            isLoading = true
        }

        let result = await SwingAnalyzer.shared.analyzeSwingVideo(at: video.videoPath)

        await MainActor.run {
            if let result = result {
                updateAnalysisResult(for: video.id, result: result)
            }
            isLoading = false
        }

        return result
    }

    /// Gets a swing video by ID
    func getSwingVideo(id: String) -> ManagedSwingVideo? {
        swingVideos.first { $0.id == id }
    }

    // MARK: - Persistence

    private func loadSwingVideos() {
        guard fileManager.fileExists(atPath: metadataURL.path),
              let data = try? Data(contentsOf: metadataURL) else {
            swingVideos = []
            return
        }

        do {
            let decoder = JSONDecoder()
            let loadedVideos = try decoder.decode([ManagedSwingVideo].self, from: data)

            // Filter out videos whose files no longer exist
            swingVideos = loadedVideos.filter { video in
                fileManager.fileExists(atPath: video.videoPath)
            }

            // Save if we filtered any out
            if swingVideos.count != loadedVideos.count {
                saveMetadata()
            }
        } catch {
            print("Failed to load swing videos: \(error)")
            swingVideos = []
        }
    }

    private func saveMetadata() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(swingVideos)
            try data.write(to: metadataURL)
        } catch {
            print("Failed to save swing video metadata: \(error)")
        }
    }

    // MARK: - Helpers

    /// Gets the most recent analysis for comparison
    func getMostRecentAnalysis() -> SwingAnalysisResult? {
        swingVideos
            .compactMap { $0.analysisResult }
            .sorted { $0.analyzedAt > $1.analyzedAt }
            .first
    }

    /// Gets average score across all analyzed videos
    func getAverageScore() -> Int? {
        let scores = swingVideos.compactMap { $0.analysisResult?.overallScore }
        guard !scores.isEmpty else { return nil }
        return scores.reduce(0, +) / scores.count
    }

    /// Clears all swing videos (for account deletion)
    func clearAllSwingVideos() {
        for video in swingVideos {
            try? fileManager.removeItem(atPath: video.videoPath)
        }
        swingVideos = []
        try? fileManager.removeItem(at: metadataURL)
    }
}

// MARK: - Preview Support

extension SwingVideoManager {
    static var preview: SwingVideoManager {
        let manager = SwingVideoManager()
        manager.swingVideos = [
            ManagedSwingVideo(
                id: "preview-1",
                videoPath: "/path/to/video1.mp4",
                type: .downTheLine,
                annotation: "Working on staying centered over the ball",
                analysisResult: SwingAnalysisResult(
                    videoId: "preview-1",
                    overallScore: 82,
                    breakdown: [
                        SwingPhaseScore(phase: .grip, score: 85, feedback: "Solid neutral grip"),
                        SwingPhaseScore(phase: .stance, score: 80, feedback: "Good width"),
                        SwingPhaseScore(phase: .backswing, score: 88, feedback: "Full turn"),
                        SwingPhaseScore(phase: .downswing, score: 78, feedback: "Maintain lag"),
                        SwingPhaseScore(phase: .impact, score: 82, feedback: "Square face"),
                        SwingPhaseScore(phase: .followThrough, score: 75, feedback: "Extend more")
                    ],
                    tips: [
                        SwingTip(icon: "hand.raised.fill", title: "Maintain Lag", description: "Keep wrists cocked longer"),
                        SwingTip(icon: "arrow.right", title: "Extend Through", description: "Push toward target")
                    ],
                    drills: [
                        RecommendedDrill(title: "Lag Drill", duration: "10 min", description: "Slow motion practice", targetPhase: .downswing)
                    ],
                    improvement: 5
                )
            ),
            ManagedSwingVideo(
                id: "preview-2",
                videoPath: "/path/to/video2.mp4",
                type: .faceOn,
                annotation: "Focusing on reducing head sway"
            )
        ]
        return manager
    }
}
