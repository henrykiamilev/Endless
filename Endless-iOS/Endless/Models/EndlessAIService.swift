import Foundation
import Combine
import SwiftUI

/// Main orchestrator for all Endless AI features
class EndlessAIService: ObservableObject {
    static let shared = EndlessAIService()

    // MARK: - Sub-services

    let highlightGenerator = HighlightReelGenerator.shared
    let swingAnalyzer = SwingAnalyzer.shared
    let swingVideoManager = SwingVideoManager.shared
    let aiCoach = AICoachService.shared

    // MARK: - Published State

    @Published var isProcessing = false
    @Published var currentTask: AITask?
    @Published var lastError: String?

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupBindings()
    }

    private func setupBindings() {
        // Aggregate processing state from sub-services
        Publishers.CombineLatest3(
            highlightGenerator.$isGenerating,
            swingAnalyzer.$isAnalyzing,
            swingVideoManager.$isLoading
        )
        .map { $0 || $1 || $2 }
        .receive(on: DispatchQueue.main)
        .assign(to: &$isProcessing)
    }

    // MARK: - User Context

    /// Sets the current user for all AI services
    func setCurrentUser(userId: String) {
        swingVideoManager.setCurrentUser(userId: userId)
    }

    /// Clears the current user from all AI services
    func clearCurrentUser() {
        swingVideoManager.clearCurrentUser()
        aiCoach.clearConversation()
    }

    // MARK: - Highlight Reel Generation

    /// Generates a highlight reel from the user's videos
    @MainActor
    func generateHighlightReel(
        from videos: [Video],
        prompt: String,
        courses: [String] = []
    ) async throws -> HighlightReelResult {
        currentTask = .highlightGeneration
        lastError = nil

        defer {
            currentTask = nil
        }

        let config = HighlightReelConfig(
            prompt: prompt,
            selectedCourses: courses
        )

        do {
            return try await highlightGenerator.generateHighlightReel(from: videos, config: config)
        } catch {
            lastError = error.localizedDescription
            throw error
        }
    }

    // MARK: - Swing Analysis

    /// Analyzes a swing video
    @MainActor
    func analyzeSwingVideo(at path: String) async -> SwingAnalysisResult? {
        currentTask = .swingAnalysis
        lastError = nil

        defer {
            currentTask = nil
        }

        let result = await swingAnalyzer.analyzeSwingVideo(at: path)

        if result == nil {
            lastError = "Failed to analyze swing video"
        }

        return result
    }

    /// Analyzes a managed swing video and updates its analysis result
    @MainActor
    func analyzeSwingVideo(_ video: ManagedSwingVideo) async -> SwingAnalysisResult? {
        currentTask = .swingAnalysis
        lastError = nil

        defer {
            currentTask = nil
        }

        let result = await swingVideoManager.analyzeSwingVideo(video)

        if result == nil {
            lastError = "Failed to analyze swing video"
        } else if let result = result {
            // Update AI Coach with the new analysis
            aiCoach.setAnalysisContext(result)
        }

        return result
    }

    /// Gets a quick quality score for a video (for highlight reel ranking)
    func getClipQualityScore(at path: String) async -> Double {
        return await swingAnalyzer.getClipQualityScore(at: path)
    }

    // MARK: - Swing Video Management

    /// Adds a new swing video
    func addSwingVideo(
        from sourceURL: URL,
        type: SwingVideoType,
        annotation: String,
        completion: @escaping (ManagedSwingVideo?) -> Void
    ) {
        swingVideoManager.addSwingVideo(
            from: sourceURL,
            type: type,
            annotation: annotation,
            completion: completion
        )
    }

    /// Deletes a swing video
    func deleteSwingVideo(_ video: ManagedSwingVideo) {
        swingVideoManager.deleteSwingVideo(video)
    }

    /// Gets all swing videos
    var swingVideos: [ManagedSwingVideo] {
        swingVideoManager.swingVideos
    }

    /// Checks if more swing videos can be added
    var canAddMoreSwingVideos: Bool {
        swingVideoManager.canAddMoreVideos
    }

    // MARK: - AI Coach

    /// Sends a message to the AI Coach
    func sendCoachMessage(_ text: String) {
        aiCoach.sendMessage(text)
    }

    /// Sets the analysis context for the AI Coach
    func setCoachAnalysisContext(_ analysis: SwingAnalysisResult?) {
        aiCoach.setAnalysisContext(analysis)
    }

    /// Clears the AI Coach conversation
    func clearCoachConversation() {
        aiCoach.clearConversation()
    }

    /// Gets the AI Coach messages
    var coachMessages: [AICoachMessage] {
        aiCoach.messages
    }

    // MARK: - Utility

    /// Gets the overall analysis progress (0-1)
    var analysisProgress: Double {
        if highlightGenerator.isGenerating {
            return highlightGenerator.generationProgress
        }
        if swingAnalyzer.isAnalyzing {
            return swingAnalyzer.analysisProgress
        }
        return 0
    }

    /// Gets the current status message
    var statusMessage: String {
        if highlightGenerator.isGenerating {
            return highlightGenerator.currentStatus
        }
        if swingAnalyzer.isAnalyzing {
            return "Analyzing swing..."
        }
        if swingVideoManager.isLoading {
            return "Loading..."
        }
        return ""
    }
}

// MARK: - AI Task Types

enum AITask {
    case highlightGeneration
    case swingAnalysis
    case videoProcessing

    var displayName: String {
        switch self {
        case .highlightGeneration:
            return "Generating Highlight Reel"
        case .swingAnalysis:
            return "Analyzing Swing"
        case .videoProcessing:
            return "Processing Video"
        }
    }

    var icon: String {
        switch self {
        case .highlightGeneration:
            return "film.stack"
        case .swingAnalysis:
            return "figure.golf"
        case .videoProcessing:
            return "video.fill"
        }
    }
}

// MARK: - SwiftUI Environment Integration

private struct EndlessAIServiceKey: EnvironmentKey {
    static let defaultValue = EndlessAIService.shared
}

extension EnvironmentValues {
    var endlessAI: EndlessAIService {
        get { self[EndlessAIServiceKey.self] }
        set { self[EndlessAIServiceKey.self] = newValue }
    }
}

// MARK: - View Modifier for Easy Access

extension View {
    func withEndlessAI() -> some View {
        self.environmentObject(EndlessAIService.shared)
            .environmentObject(SwingVideoManager.shared)
            .environmentObject(AICoachService.shared)
    }
}
