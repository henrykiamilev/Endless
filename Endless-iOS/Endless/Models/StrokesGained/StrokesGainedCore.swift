import Foundation
import CoreLocation

// MARK: - Strokes Gained Core Engine
// Core module for computing strokes gained analytics

// MARK: - Strokes Gained Category

enum SGCategory: String, Codable, CaseIterable, Identifiable {
    case offTheTee = "OTT"
    case approach = "APP"
    case shortGame = "ARG"  // Around the Green
    case putting = "PUTT"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .offTheTee: return "Tee"
        case .approach: return "Approach"
        case .shortGame: return "Short Game"
        case .putting: return "Putting"
        }
    }

    var fullName: String {
        switch self {
        case .offTheTee: return "Off the Tee"
        case .approach: return "Approach"
        case .shortGame: return "Around the Green"
        case .putting: return "Putting"
        }
    }

    var icon: String {
        switch self {
        case .offTheTee: return "figure.golf"
        case .approach: return "arrow.up.right"
        case .shortGame: return "flag.fill"
        case .putting: return "circle.fill"
        }
    }

    var color: String {
        switch self {
        case .offTheTee: return "teeColor"       // Green bar in screenshot
        case .approach: return "approachColor"   // Red bar in screenshot
        case .shortGame: return "shortGameColor" // Green bar in screenshot
        case .putting: return "puttingColor"     // Blue bar in screenshot
        }
    }

    // Distance thresholds for this category (in yards)
    var distanceRange: ClosedRange<Double>? {
        switch self {
        case .offTheTee: return nil  // Determined by hole type, not distance
        case .approach: return 50...300  // Approach shots 50+ yards
        case .shortGame: return 0...50   // Short game is <50 yards
        case .putting: return nil  // On the green (feet, not yards)
        }
    }
}

// MARK: - Lie Types

enum Lie: String, Codable, CaseIterable {
    case tee
    case fairway
    case rough
    case deepRough
    case bunker
    case green
    case fringe
    case recovery
    case unknown

    var displayName: String {
        switch self {
        case .tee: return "Tee"
        case .fairway: return "Fairway"
        case .rough: return "Rough"
        case .deepRough: return "Deep Rough"
        case .bunker: return "Sand"
        case .green: return "Green"
        case .fringe: return "Fringe"
        case .recovery: return "Recovery"
        case .unknown: return "Unknown"
        }
    }
}

// MARK: - Shot Type

enum ShotType: String, Codable, CaseIterable {
    case drive
    case approach
    case chip
    case pitch
    case bunkerShot
    case putt
    case penalty
    case unknown

    var displayName: String {
        switch self {
        case .drive: return "Drive"
        case .approach: return "Approach"
        case .chip: return "Chip"
        case .pitch: return "Pitch"
        case .bunkerShot: return "Bunker"
        case .putt: return "Putt"
        case .penalty: return "Penalty"
        case .unknown: return "Unknown"
        }
    }
}

// MARK: - Distance Bands (for Approach)

enum ApproachDistanceBand: String, Codable, CaseIterable {
    case band50_75 = "50-75"
    case band76_100 = "76-100"
    case band101_150 = "101-150"
    case band151_200 = "151-200"
    case band201_230 = "201-230"
    case band230Plus = "230+"

    var range: ClosedRange<Double> {
        switch self {
        case .band50_75: return 50...75
        case .band76_100: return 76...100
        case .band101_150: return 101...150
        case .band151_200: return 151...200
        case .band201_230: return 201...230
        case .band230Plus: return 231...400
        }
    }

    static func band(for distance: Double) -> ApproachDistanceBand? {
        for band in allCases {
            if band.range.contains(distance) {
                return band
            }
        }
        return distance > 230 ? .band230Plus : nil
    }
}

// MARK: - Short Game Distance Bands

enum ShortGameDistanceBand: String, Codable, CaseIterable {
    case band0_10 = "0-10"
    case band11_20 = "11-20"
    case band21_30 = "21-30"
    case band31_40 = "31-40"
    case band41_50 = "41-50"

    var range: ClosedRange<Double> {
        switch self {
        case .band0_10: return 0...10
        case .band11_20: return 11...20
        case .band21_30: return 21...30
        case .band31_40: return 31...40
        case .band41_50: return 41...50
        }
    }

    static func band(for distance: Double) -> ShortGameDistanceBand? {
        for band in allCases {
            if band.range.contains(distance) {
                return band
            }
        }
        return nil
    }
}

// MARK: - Putting Distance Bands

enum PuttingDistanceBand: String, Codable, CaseIterable {
    case band3_4 = "3-4'"
    case band5_8 = "5-8'"
    case band9_10 = "9-10'"
    case band11_15 = "11-15'"
    case band16_20 = "16-20'"
    case band21_25 = "21-25'"
    case band26Plus = "26'+"

    var range: ClosedRange<Double> {
        switch self {
        case .band3_4: return 3...4
        case .band5_8: return 5...8
        case .band9_10: return 9...10
        case .band11_15: return 11...15
        case .band16_20: return 16...20
        case .band21_25: return 21...25
        case .band26Plus: return 26...200
        }
    }

    static func band(for distanceFeet: Double) -> PuttingDistanceBand? {
        for band in allCases {
            if band.range.contains(distanceFeet) {
                return band
            }
        }
        return distanceFeet > 25 ? .band26Plus : nil
    }
}

// MARK: - Shot Data

struct ShotData: Codable, Identifiable {
    let id: String
    var roundId: String?
    var holeNumber: Int
    var shotNumber: Int

    // Location
    var startLie: Lie
    var endLie: Lie
    var startDistanceYards: Double  // Distance to pin in yards
    var endDistanceYards: Double    // For putts, this is in feet
    var startDistanceFeet: Double?  // For putts
    var endDistanceFeet: Double?

    // Classification
    var shotType: ShotType
    var category: SGCategory

    // Results
    var strokesGained: Double?
    var isHoled: Bool
    var isPenalty: Bool

    // Video reference
    var videoTimestamp: Double?

    init(
        id: String = UUID().uuidString,
        holeNumber: Int,
        shotNumber: Int,
        startLie: Lie,
        endLie: Lie,
        startDistanceYards: Double,
        endDistanceYards: Double,
        shotType: ShotType,
        category: SGCategory
    ) {
        self.id = id
        self.holeNumber = holeNumber
        self.shotNumber = shotNumber
        self.startLie = startLie
        self.endLie = endLie
        self.startDistanceYards = startDistanceYards
        self.endDistanceYards = endDistanceYards
        self.shotType = shotType
        self.category = category
        self.isHoled = false
        self.isPenalty = false
    }
}

// MARK: - Round Summary

struct RoundSummary: Codable, Identifiable {
    let id: String
    var roundDate: Date
    var courseName: String?
    var totalScore: Int?
    var par: Int?

    // Total Strokes Gained
    var totalStrokesGained: Double

    // Strokes Gained by Category
    var sgOffTheTee: Double
    var sgApproach: Double
    var sgShortGame: Double
    var sgPutting: Double

    // Shot counts
    var totalShots: Int
    var shotsByCategory: [SGCategory: Int]

    // Detailed statistics
    var scoringStats: ScoringStatistics
    var teeStats: TeeStatistics
    var approachStats: ApproachStatistics
    var shortGameStats: ShortGameStatistics
    var puttingStats: PuttingStatistics

    // Confidence
    var overallConfidence: Double

    init(id: String = UUID().uuidString, courseName: String? = nil) {
        self.id = id
        self.roundDate = Date()
        self.courseName = courseName
        self.totalStrokesGained = 0
        self.sgOffTheTee = 0
        self.sgApproach = 0
        self.sgShortGame = 0
        self.sgPutting = 0
        self.totalShots = 0
        self.shotsByCategory = [:]
        self.scoringStats = ScoringStatistics()
        self.teeStats = TeeStatistics()
        self.approachStats = ApproachStatistics()
        self.shortGameStats = ShortGameStatistics()
        self.puttingStats = PuttingStatistics()
        self.overallConfidence = 0
    }

    func sg(for category: SGCategory) -> Double {
        switch category {
        case .offTheTee: return sgOffTheTee
        case .approach: return sgApproach
        case .shortGame: return sgShortGame
        case .putting: return sgPutting
        }
    }
}

// MARK: - Expected Strokes Table

struct ExpectedStrokesTable {

    // Expected strokes from various lies and distances
    // Based on PGA Tour averages

    static func expectedStrokes(lie: Lie, distanceYards: Double) -> Double {
        switch lie {
        case .tee:
            return expectedStrokesFromTee(distance: distanceYards)
        case .fairway:
            return expectedStrokesFromFairway(distance: distanceYards)
        case .rough:
            return expectedStrokesFromRough(distance: distanceYards)
        case .bunker:
            return expectedStrokesFromBunker(distance: distanceYards)
        case .green:
            // Distance is in feet for green
            return expectedStrokesOnGreen(distanceFeet: distanceYards)
        case .fringe:
            return expectedStrokesFromFringe(distance: distanceYards)
        default:
            return expectedStrokesFromRough(distance: distanceYards) + 0.3
        }
    }

    static func expectedStrokesFromTee(distance: Double) -> Double {
        // Approximation based on hole yardage
        if distance < 200 { return 2.9 }        // Par 3
        if distance < 400 { return 3.8 }        // Short Par 4
        if distance < 475 { return 4.0 }        // Par 4
        if distance < 550 { return 4.7 }        // Par 5
        return 5.0
    }

    static func expectedStrokesFromFairway(distance: Double) -> Double {
        // Expected strokes from fairway by distance
        if distance < 50 { return 2.40 }
        if distance < 75 { return 2.60 }
        if distance < 100 { return 2.75 }
        if distance < 125 { return 2.85 }
        if distance < 150 { return 2.95 }
        if distance < 175 { return 3.05 }
        if distance < 200 { return 3.15 }
        if distance < 225 { return 3.30 }
        return 3.45
    }

    static func expectedStrokesFromRough(distance: Double) -> Double {
        // Add ~0.1-0.2 strokes penalty from rough
        return expectedStrokesFromFairway(distance: distance) + 0.15
    }

    static func expectedStrokesFromBunker(distance: Double) -> Double {
        // Greenside bunker
        if distance < 30 {
            return 2.45
        }
        // Fairway bunker
        return expectedStrokesFromFairway(distance: distance) + 0.25
    }

    static func expectedStrokesFromFringe(distance: Double) -> Double {
        // Just off the green
        return 2.15 + (distance * 0.02)
    }

    static func expectedStrokesOnGreen(distanceFeet: Double) -> Double {
        // PGA Tour putting averages
        if distanceFeet < 3 { return 1.00 }
        if distanceFeet < 4 { return 1.05 }
        if distanceFeet < 5 { return 1.10 }
        if distanceFeet < 6 { return 1.15 }
        if distanceFeet < 8 { return 1.25 }
        if distanceFeet < 10 { return 1.35 }
        if distanceFeet < 15 { return 1.50 }
        if distanceFeet < 20 { return 1.65 }
        if distanceFeet < 25 { return 1.75 }
        if distanceFeet < 30 { return 1.85 }
        if distanceFeet < 40 { return 1.95 }
        return 2.05
    }
}

// MARK: - Strokes Gained Calculator

struct StrokesGainedCalculator {

    /// Calculate strokes gained for a single shot
    func calculate(shot: ShotData) -> Double {
        let startExpected: Double
        let endExpected: Double

        if shot.category == .putting {
            // For putts, use feet
            let startFeet = shot.startDistanceFeet ?? shot.startDistanceYards
            let endFeet = shot.endDistanceFeet ?? shot.endDistanceYards

            startExpected = ExpectedStrokesTable.expectedStrokesOnGreen(distanceFeet: startFeet)

            if shot.isHoled {
                endExpected = 0
            } else {
                endExpected = ExpectedStrokesTable.expectedStrokesOnGreen(distanceFeet: endFeet)
            }
        } else {
            startExpected = ExpectedStrokesTable.expectedStrokes(lie: shot.startLie, distanceYards: shot.startDistanceYards)

            if shot.isHoled {
                endExpected = 0
            } else if shot.endLie == .green {
                // Convert to feet for green
                let endFeet = shot.endDistanceYards * 3  // Approximate yards to feet on green
                endExpected = ExpectedStrokesTable.expectedStrokesOnGreen(distanceFeet: endFeet)
            } else {
                endExpected = ExpectedStrokesTable.expectedStrokes(lie: shot.endLie, distanceYards: shot.endDistanceYards)
            }
        }

        // SG = Expected at start - (1 + Expected at end)
        let strokesGained = startExpected - (1.0 + endExpected)

        // Penalty adjustment
        if shot.isPenalty {
            return strokesGained - 1.0
        }

        return strokesGained
    }

    /// Calculate total strokes gained for a round
    func calculateRound(shots: [ShotData]) -> RoundSummary {
        var summary = RoundSummary()

        var sgByCategory: [SGCategory: Double] = [:]
        var shotsByCategory: [SGCategory: Int] = [:]

        for category in SGCategory.allCases {
            sgByCategory[category] = 0
            shotsByCategory[category] = 0
        }

        for shot in shots {
            var mutableShot = shot
            let sg = calculate(shot: shot)
            mutableShot.strokesGained = sg

            sgByCategory[shot.category, default: 0] += sg
            shotsByCategory[shot.category, default: 0] += 1
        }

        summary.sgOffTheTee = sgByCategory[.offTheTee] ?? 0
        summary.sgApproach = sgByCategory[.approach] ?? 0
        summary.sgShortGame = sgByCategory[.shortGame] ?? 0
        summary.sgPutting = sgByCategory[.putting] ?? 0

        summary.totalStrokesGained = summary.sgOffTheTee + summary.sgApproach + summary.sgShortGame + summary.sgPutting
        summary.totalShots = shots.count
        summary.shotsByCategory = shotsByCategory

        return summary
    }
}

// MARK: - Shot Row Display Model

struct ShotRowModel: Identifiable {
    let id: String
    let holeNumber: Int
    let shotIndex: Int
    let startLie: Lie
    let endLie: Lie
    let startDistDisplay: String
    let endDistDisplay: String
    let strokesGained: Double?
    let category: SGCategory
    let isHoled: Bool
    let needsReview: Bool
    let confidence: ShotConfidence

    var sgFormatted: String {
        guard let sg = strokesGained else { return "--" }
        if sg >= 0 {
            return String(format: "+%.2f", sg)
        } else {
            return String(format: "%.2f", sg)
        }
    }

    init(from shot: ShotData) {
        self.id = shot.id
        self.holeNumber = shot.holeNumber
        self.shotIndex = shot.shotNumber
        self.startLie = shot.startLie
        self.endLie = shot.endLie
        self.strokesGained = shot.strokesGained
        self.category = shot.category
        self.isHoled = shot.isHoled
        self.needsReview = false
        self.confidence = ShotConfidence()

        // Format distances
        if shot.category == .putting {
            let startFt = shot.startDistanceFeet ?? shot.startDistanceYards
            let endFt = shot.endDistanceFeet ?? shot.endDistanceYards
            self.startDistDisplay = String(format: "%.0f ft", startFt)
            self.endDistDisplay = shot.isHoled ? "Holed" : String(format: "%.0f ft", endFt)
        } else {
            self.startDistDisplay = String(format: "%.0f yds", shot.startDistanceYards)
            self.endDistDisplay = shot.isHoled ? "Holed" : String(format: "%.0f yds", shot.endDistanceYards)
        }
    }
}

// MARK: - Shot Confidence

struct ShotConfidence: Codable {
    var holeConfidence: Double = 0.8
    var startLocationConfidence: Double = 0.8
    var endLocationConfidence: Double = 0.8
    var distanceConfidence: Double = 0.8
    var lieConfidence: Double = 0.8
    var shotTypeConfidence: Double = 0.8

    var overall: Double {
        (holeConfidence + startLocationConfidence + endLocationConfidence +
         distanceConfidence + lieConfidence + shotTypeConfidence) / 6.0
    }

    var isHighConfidence: Bool {
        overall >= 0.7
    }

    var needsReview: Bool {
        overall < 0.5
    }
}
