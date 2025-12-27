import Foundation

// MARK: - Round Summary V2

/// Comprehensive round summary with all SG breakdowns
struct RoundSummaryV2: Codable, Identifiable {
    let id: String
    let roundId: String
    let courseName: String?
    let date: Date
    let totalStrokes: Int

    // Total Strokes Gained
    var totalSG: Double

    // SG by Category
    var sgByCategory: [SGCategory: Double]

    // SG by Distance Band (approach shots)
    var sgByDistanceBand: [DistanceBand: Double]

    // SG by Putting Band
    var sgByPuttingBand: [PuttingBand: Double]

    // SG by Hole
    var sgByHole: [Int: Double]

    // Shot counts
    var shotsByCategory: [SGCategory: Int]
    var shotsByDistanceBand: [DistanceBand: Int]
    var shotsByPuttingBand: [PuttingBand: Int]

    // Top wins and leaks
    var topWins: [InsightCard]
    var topLeaks: [InsightCard]

    // Confidence stats
    var confidenceStats: ConfidenceStats

    // Adjusted totals (high confidence only)
    var adjustedTotalSG: Double?
    var adjustedSGByCategory: [SGCategory: Double]?

    init(roundId: String, courseName: String? = nil, date: Date = Date(), totalStrokes: Int = 0) {
        self.id = UUID().uuidString
        self.roundId = roundId
        self.courseName = courseName
        self.date = date
        self.totalStrokes = totalStrokes
        self.totalSG = 0
        self.sgByCategory = [:]
        self.sgByDistanceBand = [:]
        self.sgByPuttingBand = [:]
        self.sgByHole = [:]
        self.shotsByCategory = [:]
        self.shotsByDistanceBand = [:]
        self.shotsByPuttingBand = [:]
        self.topWins = []
        self.topLeaks = []
        self.confidenceStats = ConfidenceStats()
    }

    // MARK: - Helpers

    var formattedTotalSG: String {
        formatSG(totalSG)
    }

    func formattedSG(for category: SGCategory) -> String {
        formatSG(sgByCategory[category] ?? 0)
    }

    private func formatSG(_ value: Double) -> String {
        if value >= 0 {
            return String(format: "+%.2f", value)
        } else {
            return String(format: "%.2f", value)
        }
    }

    var biggestLeak: SGCategory? {
        sgByCategory.min(by: { $0.value < $1.value })?.key
    }

    var biggestStrength: SGCategory? {
        sgByCategory.max(by: { $0.value < $1.value })?.key
    }
}

/// Confidence statistics for a round
struct ConfidenceStats: Codable {
    var totalShots: Int = 0
    var highConfidenceShots: Int = 0
    var needsReviewShots: Int = 0
    var excludedShots: Int = 0

    var highConfidencePercent: Double {
        guard totalShots > 0 else { return 0 }
        return Double(highConfidenceShots) / Double(totalShots) * 100
    }

    var autoConfirmedPercent: String {
        String(format: "%.0f%% auto-confirmed", highConfidencePercent)
    }
}

// MARK: - Insight Card

/// A single insight about performance
struct InsightCard: Codable, Identifiable {
    let id: String
    let type: InsightType
    let title: String
    let description: String
    let value: Double?
    let category: SGCategory?
    let shotIds: [String]

    enum InsightType: String, Codable {
        case win
        case leak
        case trend
        case tip
    }

    init(type: InsightType, title: String, description: String, value: Double? = nil,
         category: SGCategory? = nil, shotIds: [String] = []) {
        self.id = UUID().uuidString
        self.type = type
        self.title = title
        self.description = description
        self.value = value
        self.category = category
        self.shotIds = shotIds
    }
}

// MARK: - Shot Row Model (for UI)

/// Model for displaying a shot in the shot table
struct ShotRowModel: Identifiable {
    let id: String
    let holeNumber: Int
    let shotIndex: Int  // 1-indexed

    // Start state
    let startDistDisplay: String
    let startLie: Lie
    let startExpected: Double?

    // End state
    let endDistDisplay: String
    let endLie: Lie
    let endExpected: Double?

    // Results
    let penaltyStrokes: Int
    let strokesGained: Double?
    let sgFormatted: String

    // Status
    let isHoled: Bool
    let confidence: ShotConfidence
    let needsReview: Bool
    let flags: [String]

    // Video deep link
    let clipStart: Double?
    let impactTime: Double?
    let clipEnd: Double?

    init(from shot: DerivedShot) {
        self.id = shot.id
        self.holeNumber = shot.holeNumber.value ?? 0
        self.shotIndex = shot.shotNumber

        // Format distances
        let startLieValue = shot.startState.lie.value ?? .unknown
        let isPuttingStart = startLieValue == .green

        if let startDist = shot.startState.distanceToPin.value {
            if isPuttingStart {
                self.startDistDisplay = String(format: "%.0f ft", startDist)
            } else {
                self.startDistDisplay = String(format: "%.0f yds", startDist)
            }
        } else {
            self.startDistDisplay = "--"
        }

        self.startLie = startLieValue
        self.startExpected = shot.startState.expectedStrokes

        let endLieValue = shot.endState.lie.value ?? .unknown
        let isPuttingEnd = endLieValue == .green

        if shot.isHoled {
            self.endDistDisplay = "Holed"
            self.endLie = .green
        } else if let endDist = shot.endState.distanceToPin.value {
            if isPuttingEnd {
                self.endDistDisplay = String(format: "%.0f ft", endDist)
            } else {
                self.endDistDisplay = String(format: "%.0f yds", endDist)
            }
            self.endLie = endLieValue
        } else {
            self.endDistDisplay = "--"
            self.endLie = endLieValue
        }

        self.endExpected = shot.endState.expectedStrokes
        self.penaltyStrokes = shot.penaltyStrokes

        self.strokesGained = shot.strokesGained
        if let sg = shot.strokesGained {
            if sg >= 0 {
                self.sgFormatted = String(format: "+%.2f", sg)
            } else {
                self.sgFormatted = String(format: "%.2f", sg)
            }
        } else {
            self.sgFormatted = "--"
        }

        self.isHoled = shot.isHoled
        self.confidence = shot.confidence
        self.needsReview = shot.confidence.needsReview

        var flags: [String] = []
        if shot.isPenaltyLikely { flags.append("penalty_likely") }
        if shot.confidence.needsReview { flags.append("needs_review") }
        self.flags = flags

        self.clipStart = shot.clipStartSeconds
        self.impactTime = shot.impactSeconds
        self.clipEnd = shot.clipEndSeconds
    }
}

// MARK: - Summary Builder

/// Builds RoundSummaryV2 from derived shots
final class RoundSummaryBuilder {

    func build(from shots: [DerivedShot], roundId: String, courseName: String? = nil) -> RoundSummaryV2 {
        var summary = RoundSummaryV2(roundId: roundId, courseName: courseName, totalStrokes: shots.count)

        // Aggregate by category
        var sgByCategory: [SGCategory: Double] = [:]
        var shotsByCategory: [SGCategory: Int] = [:]

        // Aggregate by distance band
        var sgByDistanceBand: [DistanceBand: Double] = [:]
        var shotsByDistanceBand: [DistanceBand: Int] = [:]

        // Aggregate by putting band
        var sgByPuttingBand: [PuttingBand: Double] = [:]
        var shotsByPuttingBand: [PuttingBand: Int] = [:]

        // Aggregate by hole
        var sgByHole: [Int: Double] = [:]

        // Confidence tracking
        var totalShots = 0
        var highConfidenceShots = 0
        var needsReviewShots = 0
        var highConfidenceSG: Double = 0

        // High confidence by category
        var highConfSGByCategory: [SGCategory: Double] = [:]

        // Track best/worst shots
        var sortedShots: [(shot: DerivedShot, sg: Double)] = []

        for shot in shots {
            guard let sg = shot.strokesGained,
                  let category = shot.category else { continue }

            totalShots += 1

            // Category aggregation
            sgByCategory[category, default: 0] += sg
            shotsByCategory[category, default: 0] += 1

            // Hole aggregation
            if let holeNum = shot.holeNumber.value {
                sgByHole[holeNum, default: 0] += sg
            }

            // Distance band aggregation (for non-putting)
            if category != .putting, let dist = shot.startState.distanceToPin.value {
                let band = DistanceBand.band(for: dist)
                sgByDistanceBand[band, default: 0] += sg
                shotsByDistanceBand[band, default: 0] += 1
            }

            // Putting band aggregation
            if category == .putting, let dist = shot.startState.distanceToPin.value {
                let band = PuttingBand.band(for: dist)
                sgByPuttingBand[band, default: 0] += sg
                shotsByPuttingBand[band, default: 0] += 1
            }

            // Confidence tracking
            if shot.confidence.isHighConfidence {
                highConfidenceShots += 1
                highConfidenceSG += sg
                highConfSGByCategory[category, default: 0] += sg
            }
            if shot.confidence.needsReview {
                needsReviewShots += 1
            }

            sortedShots.append((shot, sg))
        }

        // Set aggregates
        summary.totalSG = sgByCategory.values.reduce(0, +)
        summary.sgByCategory = sgByCategory
        summary.shotsByCategory = shotsByCategory
        summary.sgByDistanceBand = sgByDistanceBand
        summary.shotsByDistanceBand = shotsByDistanceBand
        summary.sgByPuttingBand = sgByPuttingBand
        summary.shotsByPuttingBand = shotsByPuttingBand
        summary.sgByHole = sgByHole

        // Confidence stats
        summary.confidenceStats = ConfidenceStats(
            totalShots: totalShots,
            highConfidenceShots: highConfidenceShots,
            needsReviewShots: needsReviewShots,
            excludedShots: 0
        )

        // Adjusted totals
        summary.adjustedTotalSG = highConfidenceSG
        summary.adjustedSGByCategory = highConfSGByCategory

        // Generate insights
        summary.topWins = generateWins(from: sortedShots)
        summary.topLeaks = generateLeaks(from: sortedShots)

        return summary
    }

    private func generateWins(from shots: [(shot: DerivedShot, sg: Double)]) -> [InsightCard] {
        let sorted = shots.sorted { $0.sg > $1.sg }
        return sorted.prefix(3).compactMap { item -> InsightCard? in
            let shot = item.shot
            guard let category = shot.category else { return nil }

            let title: String
            switch category {
            case .offTheTee:
                title = "Great Drive"
            case .approach:
                title = "Excellent Approach"
            case .shortGame:
                title = "Clutch Short Game"
            case .putting:
                title = "Key Putt Made"
            }

            let description: String
            if let holeNum = shot.holeNumber.value {
                description = "Hole \(holeNum), Shot \(shot.shotNumber): Gained \(String(format: "%.2f", item.sg)) strokes"
            } else {
                description = "Gained \(String(format: "%.2f", item.sg)) strokes"
            }

            return InsightCard(
                type: .win,
                title: title,
                description: description,
                value: item.sg,
                category: category,
                shotIds: [shot.id]
            )
        }
    }

    private func generateLeaks(from shots: [(shot: DerivedShot, sg: Double)]) -> [InsightCard] {
        let sorted = shots.sorted { $0.sg < $1.sg }
        return sorted.prefix(3).compactMap { item -> InsightCard? in
            let shot = item.shot
            guard let category = shot.category else { return nil }

            let title: String
            switch category {
            case .offTheTee:
                title = "Tee Shot Trouble"
            case .approach:
                title = "Missed Approach"
            case .shortGame:
                title = "Short Game Miss"
            case .putting:
                title = "Putting Struggle"
            }

            let description: String
            if let holeNum = shot.holeNumber.value {
                description = "Hole \(holeNum), Shot \(shot.shotNumber): Lost \(String(format: "%.2f", abs(item.sg))) strokes"
            } else {
                description = "Lost \(String(format: "%.2f", abs(item.sg))) strokes"
            }

            return InsightCard(
                type: .leak,
                title: title,
                description: description,
                value: item.sg,
                category: category,
                shotIds: [shot.id]
            )
        }
    }
}

// MARK: - Insight Generator

/// Generates coaching insights from round data
final class InsightGenerator {

    /// Generate focus points based on SG patterns
    func generateFocusPoints(from summary: RoundSummaryV2) -> [InsightCard] {
        var insights: [InsightCard] = []

        // Find biggest leak category
        if let weakest = summary.sgByCategory.min(by: { $0.value < $1.value }),
           weakest.value < -0.5 {
            let insight = focusInsight(for: weakest.key, sg: weakest.value)
            insights.append(insight)
        }

        // Find worst distance band
        if let worstBand = summary.sgByDistanceBand.min(by: { $0.value < $1.value }),
           worstBand.value < -0.3 {
            let insight = InsightCard(
                type: .tip,
                title: "Distance Control: \(worstBand.key.rawValue) yards",
                description: "You're losing strokes from \(worstBand.key.rawValue) yards. Focus on this range during practice.",
                value: worstBand.value,
                category: .approach
            )
            insights.append(insight)
        }

        // Find worst putting band
        if let worstPutt = summary.sgByPuttingBand.min(by: { $0.value < $1.value }),
           worstPutt.value < -0.2 {
            let insight = InsightCard(
                type: .tip,
                title: "Putting: \(worstPutt.key.rawValue)",
                description: "Practice putts from \(worstPutt.key.rawValue). This is where you can save strokes.",
                value: worstPutt.value,
                category: .putting
            )
            insights.append(insight)
        }

        return Array(insights.prefix(3))  // Top 3 focus points
    }

    private func focusInsight(for category: SGCategory, sg: Double) -> InsightCard {
        let (title, description): (String, String)

        switch category {
        case .offTheTee:
            title = "Improve Driving Accuracy"
            description = "Focus on finding more fairways. Consider a more conservative club off the tee on tight holes."
        case .approach:
            title = "Sharpen Approach Game"
            description = "Work on distance control with your irons. Practice hitting to specific yardages, not just at the flag."
        case .shortGame:
            title = "Upgrade Short Game"
            description = "Spend time on chipping and pitching. Getting up-and-down more often will lower your scores quickly."
        case .putting:
            title = "Putt with Purpose"
            description = "Focus on lag putting to eliminate 3-putts, and dial in your reads from 4-8 feet."
        }

        return InsightCard(
            type: .tip,
            title: title,
            description: description,
            value: sg,
            category: category
        )
    }
}

// MARK: - Trends Calculator

/// Calculates trends across multiple rounds
final class TrendsCalculator {

    struct TrendData: Identifiable {
        let id = UUID()
        let period: String
        let roundCount: Int
        let totalSG: Double
        let sgByCategory: [SGCategory: Double]
        let averageSGPerRound: Double
    }

    func calculateTrends(from rounds: [RoundSummaryV2]) -> [TrendData] {
        guard !rounds.isEmpty else { return [] }

        var trends: [TrendData] = []

        // Last round
        if let lastRound = rounds.first {
            trends.append(TrendData(
                period: "Last Round",
                roundCount: 1,
                totalSG: lastRound.totalSG,
                sgByCategory: lastRound.sgByCategory,
                averageSGPerRound: lastRound.totalSG
            ))
        }

        // Last 3 rounds
        if rounds.count >= 3 {
            let last3 = Array(rounds.prefix(3))
            trends.append(aggregateTrend(rounds: last3, period: "Last 3 Rounds"))
        }

        // Last 10 rounds
        if rounds.count >= 10 {
            let last10 = Array(rounds.prefix(10))
            trends.append(aggregateTrend(rounds: last10, period: "Last 10 Rounds"))
        }

        // Season (all rounds)
        if rounds.count > 1 {
            trends.append(aggregateTrend(rounds: rounds, period: "Season"))
        }

        return trends
    }

    private func aggregateTrend(rounds: [RoundSummaryV2], period: String) -> TrendData {
        var totalSG: Double = 0
        var sgByCategory: [SGCategory: Double] = [:]

        for round in rounds {
            totalSG += round.totalSG
            for (cat, sg) in round.sgByCategory {
                sgByCategory[cat, default: 0] += sg
            }
        }

        // Average per round
        let count = Double(rounds.count)
        let avgSG = totalSG / count
        var avgByCategory: [SGCategory: Double] = [:]
        for (cat, sg) in sgByCategory {
            avgByCategory[cat] = sg / count
        }

        return TrendData(
            period: period,
            roundCount: rounds.count,
            totalSG: totalSG,
            sgByCategory: avgByCategory,
            averageSGPerRound: avgSG
        )
    }
}

// MARK: - Round Session

/// Complete round session with all shots and summary
struct RoundSession: Codable, Identifiable {
    let id: String
    var courseName: String?
    var courseId: String?
    var date: Date
    var events: [ShotEvent]
    var shots: [DerivedShot]
    var summary: RoundSummaryV2?

    init(id: String = UUID().uuidString, courseName: String? = nil, date: Date = Date()) {
        self.id = id
        self.courseName = courseName
        self.date = date
        self.events = []
        self.shots = []
    }
}

// MARK: - Round Persistence Manager

/// Manages persistence of round data
final class RoundPersistenceManager {

    static let shared = RoundPersistenceManager()

    private let fileManager = FileManager.default
    private var roundsDirectory: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("StrokesGained/Rounds", isDirectory: true)
    }

    private init() {
        createDirectoryIfNeeded()
    }

    private func createDirectoryIfNeeded() {
        try? fileManager.createDirectory(at: roundsDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Save/Load

    func save(round: RoundSession) throws {
        let url = roundsDirectory.appendingPathComponent("\(round.id).json")
        let data = try JSONEncoder().encode(round)
        try data.write(to: url)
    }

    func load(roundId: String) throws -> RoundSession? {
        let url = roundsDirectory.appendingPathComponent("\(roundId).json")
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(RoundSession.self, from: data)
    }

    func loadAllRounds() -> [RoundSession] {
        guard let files = try? fileManager.contentsOfDirectory(at: roundsDirectory, includingPropertiesForKeys: nil) else {
            return []
        }

        return files.compactMap { url -> RoundSession? in
            guard url.pathExtension == "json" else { return nil }
            return try? JSONDecoder().decode(RoundSession.self, from: Data(contentsOf: url))
        }.sorted { $0.date > $1.date }
    }

    func loadAllSummaries() -> [RoundSummaryV2] {
        loadAllRounds().compactMap { $0.summary }
    }

    func delete(roundId: String) throws {
        let url = roundsDirectory.appendingPathComponent("\(roundId).json")
        try fileManager.removeItem(at: url)
    }
}
