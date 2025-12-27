import Foundation

// MARK: - Category Statistics
// Models for detailed statistics per Strokes Gained category
// Based on professional golf analytics standards

// MARK: - Scoring Statistics (Overall Round Stats)

struct ScoringStatistics: Codable {
    // Core Scoring
    var scoringAverage: StatValue?
    var strokesGainedPutting: StatValue?

    // Par Scoring
    var par3Scoring: StatValue?
    var par4Scoring: StatValue?
    var par5Scoring: StatValue?

    // Greens in Regulation by Par
    var par3GIR: StatValue?
    var par4GIR: StatValue?
    var par5GIR: StatValue?

    // Scoring Events
    var eaglesPerRound: StatValue?
    var birdiesPerRound: StatValue?
    var bogeysPerRound: StatValue?
    var doubleBogeyPlusPerRound: StatValue?
    var doubleBogeysPerRound: StatValue?

    // Ratios
    var bogeysPerRoundPar5: StatValue?
    var birdiesToBogeys: StatValue?

    // Lie-based Scoring
    var rightRoughScoringAverage: StatValue?
    var leftRoughScoringAverage: StatValue?

    init() {}
}

// MARK: - Tee Statistics (Off the Tee)

struct TeeStatistics: Codable {
    // Accuracy
    var fairwayHitPercentage: StatValue?
    var driverSelectionPercentage: StatValue?
    var driverFairwaysHitPercentage: StatValue?

    // Miss Direction
    var teeShotLeftPercentage: StatValue?
    var teeShotRightPercentage: StatValue?

    // Trouble
    var teeShotInTreesPercentage: StatValue?
    var teeShotInSandPercentage: StatValue?
    var holesWithPenaltiesPercentage: StatValue?
    var penaltyRateOffTee: StatValue?

    // Strokes Gained
    var strokesGainedDrivingPerRound: StatValue?

    init() {}
}

// MARK: - Approach Statistics

struct ApproachStatistics: Codable {
    // Overall GIR
    var totalGIR: StatValue?

    // GIR by Distance from Fairway
    var gir75_100Fairway: StatValue?
    var gir101_150Fairway: StatValue?
    var gir151_200Fairway: StatValue?
    var gir201_230Fairway: StatValue?

    // GIR from Trouble Lies
    var girFairwayBunker: StatValue?
    var girOtherThanFairway: StatValue?
    var leftRoughGIR: StatValue?
    var rightRoughGIR: StatValue?

    // Proximity by Distance (from Fairway)
    var proximity25_75Fairway: StatValue?
    var proximity75_100Fairway: StatValue?
    var proximity100_150Fairway: StatValue?

    // Scoring Average by Distance (from Fairway)
    var scoringAvg75_100Fairway: StatValue?
    var scoringAvg101_150Fairway: StatValue?
    var scoringAvg151_200Fairway: StatValue?
    var scoringAvg201_250Fairway: StatValue?

    // Scoring Average by Distance (from Rough)
    var scoringAvg75_100Rough: StatValue?
    var scoringAvg101_150Rough: StatValue?
    var scoringAvg151_200Rough: StatValue?
    var scoringAvg201_250Rough: StatValue?

    // Strokes Gained Approach
    var strokesGainedApproachPerRound: StatValue?
    var strokesGained50_75yds: StatValue?
    var strokesGained76_100yds: StatValue?
    var strokesGained101_150yds: StatValue?
    var strokesGained151_200yds: StatValue?
    var strokesGained201_230yds: StatValue?

    init() {}
}

// MARK: - Short Game Statistics (Around the Green)

struct ShortGameStatistics: Codable {
    // Save Percentages
    var savePercentage: StatValue?
    var roughSavePercentage: StatValue?
    var sandSavePercentage: StatValue?
    var fairwaySavePercentage: StatValue?

    // Save by Distance
    var saveLessThan10yds: StatValue?
    var save10_20yds: StatValue?
    var save20_30yds: StatValue?

    // Sand Save by Distance
    var sandSaveLessThan10yds: StatValue?
    var sandSave10_20yds: StatValue?
    var sandSave20_30yds: StatValue?

    // Proximity
    var proximityToHoleFromSand: StatValue?
    var proximityToHoleFromRough: StatValue?

    // Putting on Saves
    var strokesGainedPuttingOnSaves: StatValue?

    // Chipping
    var twoChipsPerRound: StatValue?

    // Strokes Gained Short Game
    var strokesGainedShortGamePerRound: StatValue?
    var strokesGained0_10yds: StatValue?
    var strokesGained11_20yds: StatValue?
    var strokesGained21_30yds: StatValue?
    var strokesGained31_40yds: StatValue?
    var strokesGained41_50yds: StatValue?

    // Scrambling
    var nonGIRParOrBetterRate: StatValue?

    init() {}
}

// MARK: - Putting Statistics

struct PuttingStatistics: Codable {
    // Core Putting
    var strokesGainedPutting: StatValue?
    var total3PuttAvoidance: StatValue?
    var puttingSpeedRatio: StatValue?

    // Make Rate by Distance
    var makeRate3_4ft: StatValue?
    var makeRate5_8ft: StatValue?
    var makeRate9_10ft: StatValue?
    var makeRate11_15ft: StatValue?
    var makeRate16_20ft: StatValue?
    var makeRate21_25ft: StatValue?
    var makeRate26Plus: StatValue?

    // Leave Short by Distance
    var leaveShort5_10ft: StatValue?
    var leaveShort11_15ft: StatValue?
    var leaveShort16_20ft: StatValue?
    var leaveShort21_30ft: StatValue?
    var leaveShort31Plus: StatValue?

    // 3-Putt Avoidance by Distance
    var threePuttAvoidance5_10ft: StatValue?
    var threePuttAvoidance11_20ft: StatValue?
    var threePuttAvoidance21_30ft: StatValue?
    var threePuttAvoidance31Plus: StatValue?

    // GIR Putting
    var puttsPerGIR: StatValue?

    // Strokes Gained Putting by Distance
    var strokesGained3_4ft: StatValue?
    var strokesGained4_8ft: StatValue?
    var strokesGained8_10ft: StatValue?
    var strokesGained10_15ft: StatValue?
    var strokesGained15_20ft: StatValue?
    var strokesGained20_25ft: StatValue?
    var strokesGained25Plus: StatValue?

    // Long Putt Performance
    var strokesGained1stPuttOver20ft: StatValue?
    var strokesGained1stPuttOver20ftPerRound: StatValue?
    var firstPuttPerformance: StatValue?

    init() {}
}

// MARK: - Stat Value with Sample Size

struct StatValue: Codable {
    var value: Double
    var sampleSize: Int
    var timeframe: StatTimeframe

    init(value: Double, sampleSize: Int, timeframe: StatTimeframe = .season) {
        self.value = value
        self.sampleSize = sampleSize
        self.timeframe = timeframe
    }

    var displayValue: String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else if abs(value) < 1 {
            return String(format: "%.2f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }

    var displayPercentage: String {
        return String(format: "%.1f%%", value * 100)
    }

    var displaySG: String {
        if value >= 0 {
            return String(format: "+%.2f", value)
        } else {
            return String(format: "%.2f", value)
        }
    }

    var displayFeet: String {
        return String(format: "%.1f ft", value)
    }
}

// MARK: - Stat Timeframe

enum StatTimeframe: String, Codable, CaseIterable {
    case lastRound = "Last Round"
    case last3 = "Last 3"
    case last4 = "Last 4"
    case last20 = "Last 20"
    case season = "Season"

    var shortName: String {
        switch self {
        case .lastRound: return "L1"
        case .last3: return "L3"
        case .last4: return "L4"
        case .last20: return "L20"
        case .season: return "SZN"
        }
    }
}

// MARK: - Combined Round Statistics

struct RoundStatistics: Codable {
    var roundId: String
    var roundDate: Date
    var courseName: String?

    var scoring: ScoringStatistics
    var tee: TeeStatistics
    var approach: ApproachStatistics
    var shortGame: ShortGameStatistics
    var putting: PuttingStatistics

    init(roundId: String, courseName: String? = nil) {
        self.roundId = roundId
        self.roundDate = Date()
        self.courseName = courseName
        self.scoring = ScoringStatistics()
        self.tee = TeeStatistics()
        self.approach = ApproachStatistics()
        self.shortGame = ShortGameStatistics()
        self.putting = PuttingStatistics()
    }
}

// MARK: - Stat Row Display Model

struct StatRowModel: Identifiable {
    let id = UUID()
    let label: String
    let values: [StatTimeframe: StatValue]
    let displayType: StatDisplayType
    let category: StatCategory

    enum StatDisplayType {
        case number
        case percentage
        case strokesGained
        case feet
        case ratio
    }

    enum StatCategory: String, CaseIterable {
        case scoring = "Scoring"
        case tee = "Tee"
        case approach = "Approach"
        case shortGame = "Short Game"
        case putting = "Putting"
    }

    func displayValue(for timeframe: StatTimeframe) -> String {
        guard let stat = values[timeframe] else { return "-" }

        switch displayType {
        case .number:
            return stat.displayValue
        case .percentage:
            return stat.displayPercentage
        case .strokesGained:
            return stat.displaySG
        case .feet:
            return stat.displayFeet
        case .ratio:
            return stat.displayValue
        }
    }

    func sampleSize(for timeframe: StatTimeframe) -> Int {
        values[timeframe]?.sampleSize ?? 0
    }
}

// MARK: - Category Stats Builder

struct CategoryStatsBuilder {

    // Build Scoring rows from statistics
    // Includes ALL stats from the Scoring tab: scoring averages, GIR by par, scoring events, ratios
    static func buildScoringRows(from stats: ScoringStatistics) -> [StatRowModel] {
        var rows: [StatRowModel] = []

        // Core Scoring
        if let stat = stats.scoringAverage {
            rows.append(StatRowModel(
                label: "Scoring Average",
                values: [stat.timeframe: stat],
                displayType: .number,
                category: .scoring
            ))
        }

        if let stat = stats.strokesGainedPutting {
            rows.append(StatRowModel(
                label: "Strokes Gained Putting",
                values: [stat.timeframe: stat],
                displayType: .strokesGained,
                category: .scoring
            ))
        }

        // Par Scoring
        if let stat = stats.par3Scoring {
            rows.append(StatRowModel(
                label: "Par 3 Scoring",
                values: [stat.timeframe: stat],
                displayType: .number,
                category: .scoring
            ))
        }

        if let stat = stats.par4Scoring {
            rows.append(StatRowModel(
                label: "Par 4 Scoring",
                values: [stat.timeframe: stat],
                displayType: .number,
                category: .scoring
            ))
        }

        if let stat = stats.par5Scoring {
            rows.append(StatRowModel(
                label: "Par 5 Scoring",
                values: [stat.timeframe: stat],
                displayType: .number,
                category: .scoring
            ))
        }

        // GIR by Par
        if let stat = stats.par3GIR {
            rows.append(StatRowModel(
                label: "Par 3 GIR",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .scoring
            ))
        }

        if let stat = stats.par4GIR {
            rows.append(StatRowModel(
                label: "Par 4 GIR",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .scoring
            ))
        }

        if let stat = stats.par5GIR {
            rows.append(StatRowModel(
                label: "Par 5 GIR",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .scoring
            ))
        }

        // Scoring Events
        if let stat = stats.eaglesPerRound {
            rows.append(StatRowModel(
                label: "Eagles per Round",
                values: [stat.timeframe: stat],
                displayType: .number,
                category: .scoring
            ))
        }

        if let stat = stats.birdiesPerRound {
            rows.append(StatRowModel(
                label: "Birdies per Round",
                values: [stat.timeframe: stat],
                displayType: .number,
                category: .scoring
            ))
        }

        if let stat = stats.bogeysPerRound {
            rows.append(StatRowModel(
                label: "Bogeys per Round",
                values: [stat.timeframe: stat],
                displayType: .number,
                category: .scoring
            ))
        }

        if let stat = stats.doubleBogeyPlusPerRound {
            rows.append(StatRowModel(
                label: "Double Bogey+ per Round",
                values: [stat.timeframe: stat],
                displayType: .number,
                category: .scoring
            ))
        }

        if let stat = stats.doubleBogeysPerRound {
            rows.append(StatRowModel(
                label: "Double Bogeys per Round",
                values: [stat.timeframe: stat],
                displayType: .number,
                category: .scoring
            ))
        }

        // Ratios
        if let stat = stats.bogeysPerRoundPar5 {
            rows.append(StatRowModel(
                label: "Bogeys per Round/Par 5",
                values: [stat.timeframe: stat],
                displayType: .number,
                category: .scoring
            ))
        }

        if let stat = stats.birdiesToBogeys {
            rows.append(StatRowModel(
                label: "Birdies/Bogeys",
                values: [stat.timeframe: stat],
                displayType: .ratio,
                category: .scoring
            ))
        }

        // Lie-based Scoring Averages
        if let stat = stats.rightRoughScoringAverage {
            rows.append(StatRowModel(
                label: "Right Rough Scoring Average",
                values: [stat.timeframe: stat],
                displayType: .number,
                category: .scoring
            ))
        }

        if let stat = stats.leftRoughScoringAverage {
            rows.append(StatRowModel(
                label: "Left Rough Scoring Average",
                values: [stat.timeframe: stat],
                displayType: .number,
                category: .scoring
            ))
        }

        return rows
    }

    // Build Tee rows from statistics
    static func buildTeeRows(from stats: TeeStatistics) -> [StatRowModel] {
        var rows: [StatRowModel] = []

        if let stat = stats.fairwayHitPercentage {
            rows.append(StatRowModel(
                label: "FW Hit",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .tee
            ))
        }

        if let stat = stats.driverSelectionPercentage {
            rows.append(StatRowModel(
                label: "Driver Selection",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .tee
            ))
        }

        if let stat = stats.driverFairwaysHitPercentage {
            rows.append(StatRowModel(
                label: "Driver Fairways Hit",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .tee
            ))
        }

        if let stat = stats.teeShotLeftPercentage {
            rows.append(StatRowModel(
                label: "Tee Shot Left",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .tee
            ))
        }

        if let stat = stats.teeShotRightPercentage {
            rows.append(StatRowModel(
                label: "Tee Shot Right",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .tee
            ))
        }

        if let stat = stats.teeShotInTreesPercentage {
            rows.append(StatRowModel(
                label: "Tee Shot in Trees",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .tee
            ))
        }

        if let stat = stats.teeShotInSandPercentage {
            rows.append(StatRowModel(
                label: "Tee Shot in Sand",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .tee
            ))
        }

        if let stat = stats.strokesGainedDrivingPerRound {
            rows.append(StatRowModel(
                label: "Strokes Gained Driving/Round",
                values: [stat.timeframe: stat],
                displayType: .strokesGained,
                category: .tee
            ))
        }

        if let stat = stats.penaltyRateOffTee {
            rows.append(StatRowModel(
                label: "Penalty Rate off Tee",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .tee
            ))
        }

        return rows
    }

    // Build Approach rows from statistics
    static func buildApproachRows(from stats: ApproachStatistics) -> [StatRowModel] {
        var rows: [StatRowModel] = []

        if let stat = stats.totalGIR {
            rows.append(StatRowModel(
                label: "Total GIR",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .approach
            ))
        }

        // GIR by Distance
        if let stat = stats.gir75_100Fairway {
            rows.append(StatRowModel(
                label: "GIR 75-100 Fairway",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .approach
            ))
        }

        if let stat = stats.gir101_150Fairway {
            rows.append(StatRowModel(
                label: "GIR 101-150 Fairway",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .approach
            ))
        }

        if let stat = stats.gir151_200Fairway {
            rows.append(StatRowModel(
                label: "GIR 151-200 Fairway",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .approach
            ))
        }

        if let stat = stats.gir201_230Fairway {
            rows.append(StatRowModel(
                label: "GIR 201-230 Fairway",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .approach
            ))
        }

        // Proximity
        if let stat = stats.proximity75_100Fairway {
            rows.append(StatRowModel(
                label: "Proximity 75-100 Fairway",
                values: [stat.timeframe: stat],
                displayType: .feet,
                category: .approach
            ))
        }

        if let stat = stats.proximity100_150Fairway {
            rows.append(StatRowModel(
                label: "Proximity 100-150 Fairway",
                values: [stat.timeframe: stat],
                displayType: .feet,
                category: .approach
            ))
        }

        // Strokes Gained
        if let stat = stats.strokesGainedApproachPerRound {
            rows.append(StatRowModel(
                label: "Strokes Gained Approach/Round",
                values: [stat.timeframe: stat],
                displayType: .strokesGained,
                category: .approach
            ))
        }

        if let stat = stats.strokesGained76_100yds {
            rows.append(StatRowModel(
                label: "Strokes Gained 76-100yds",
                values: [stat.timeframe: stat],
                displayType: .strokesGained,
                category: .approach
            ))
        }

        if let stat = stats.strokesGained101_150yds {
            rows.append(StatRowModel(
                label: "Strokes Gained 101-150yds",
                values: [stat.timeframe: stat],
                displayType: .strokesGained,
                category: .approach
            ))
        }

        if let stat = stats.strokesGained151_200yds {
            rows.append(StatRowModel(
                label: "Strokes Gained 151-200yds",
                values: [stat.timeframe: stat],
                displayType: .strokesGained,
                category: .approach
            ))
        }

        return rows
    }

    // Build Short Game rows from statistics
    static func buildShortGameRows(from stats: ShortGameStatistics) -> [StatRowModel] {
        var rows: [StatRowModel] = []

        // Save Percentages
        if let stat = stats.savePercentage {
            rows.append(StatRowModel(
                label: "Save %",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .shortGame
            ))
        }

        if let stat = stats.roughSavePercentage {
            rows.append(StatRowModel(
                label: "Rough Save %",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .shortGame
            ))
        }

        if let stat = stats.sandSavePercentage {
            rows.append(StatRowModel(
                label: "Sand Save %",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .shortGame
            ))
        }

        // Save by Distance
        if let stat = stats.saveLessThan10yds {
            rows.append(StatRowModel(
                label: "Save % <10yds",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .shortGame
            ))
        }

        if let stat = stats.save10_20yds {
            rows.append(StatRowModel(
                label: "Save % 10-20yds",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .shortGame
            ))
        }

        if let stat = stats.save20_30yds {
            rows.append(StatRowModel(
                label: "Save % 20-30yds",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .shortGame
            ))
        }

        // Proximity
        if let stat = stats.proximityToHoleFromSand {
            rows.append(StatRowModel(
                label: "Proximity to Hole from Sand",
                values: [stat.timeframe: stat],
                displayType: .feet,
                category: .shortGame
            ))
        }

        if let stat = stats.proximityToHoleFromRough {
            rows.append(StatRowModel(
                label: "Proximity to Hole from Rough",
                values: [stat.timeframe: stat],
                displayType: .feet,
                category: .shortGame
            ))
        }

        // Strokes Gained
        if let stat = stats.strokesGainedShortGamePerRound {
            rows.append(StatRowModel(
                label: "Strokes Gained Short Game/Round",
                values: [stat.timeframe: stat],
                displayType: .strokesGained,
                category: .shortGame
            ))
        }

        if let stat = stats.strokesGained0_10yds {
            rows.append(StatRowModel(
                label: "Strokes Gained Short Game 0-10yds",
                values: [stat.timeframe: stat],
                displayType: .strokesGained,
                category: .shortGame
            ))
        }

        if let stat = stats.strokesGained11_20yds {
            rows.append(StatRowModel(
                label: "Strokes Gained Short Game 11-20yds",
                values: [stat.timeframe: stat],
                displayType: .strokesGained,
                category: .shortGame
            ))
        }

        if let stat = stats.strokesGained21_30yds {
            rows.append(StatRowModel(
                label: "Strokes Gained Short Game 21-30yds",
                values: [stat.timeframe: stat],
                displayType: .strokesGained,
                category: .shortGame
            ))
        }

        // Scrambling
        if let stat = stats.nonGIRParOrBetterRate {
            rows.append(StatRowModel(
                label: "Non-GIR Par or Better Rate",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .shortGame
            ))
        }

        return rows
    }

    // Build Putting rows from statistics
    static func buildPuttingRows(from stats: PuttingStatistics) -> [StatRowModel] {
        var rows: [StatRowModel] = []

        // Core Putting
        if let stat = stats.strokesGainedPutting {
            rows.append(StatRowModel(
                label: "Strokes Gained Putting",
                values: [stat.timeframe: stat],
                displayType: .strokesGained,
                category: .putting
            ))
        }

        if let stat = stats.total3PuttAvoidance {
            rows.append(StatRowModel(
                label: "Total 3-putt Avoidance",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .putting
            ))
        }

        if let stat = stats.puttingSpeedRatio {
            rows.append(StatRowModel(
                label: "Putting Speed Ratio",
                values: [stat.timeframe: stat],
                displayType: .ratio,
                category: .putting
            ))
        }

        // Make Rates
        if let stat = stats.makeRate3_4ft {
            rows.append(StatRowModel(
                label: "Make Rate 3-4'",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .putting
            ))
        }

        if let stat = stats.makeRate5_8ft {
            rows.append(StatRowModel(
                label: "Make Rate 5-8'",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .putting
            ))
        }

        if let stat = stats.makeRate9_10ft {
            rows.append(StatRowModel(
                label: "Make Rate 9-10'",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .putting
            ))
        }

        if let stat = stats.makeRate11_15ft {
            rows.append(StatRowModel(
                label: "Make Rate 11-15'",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .putting
            ))
        }

        if let stat = stats.makeRate16_20ft {
            rows.append(StatRowModel(
                label: "Make Rate 16-20'",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .putting
            ))
        }

        if let stat = stats.makeRate21_25ft {
            rows.append(StatRowModel(
                label: "Make Rate 21-25'",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .putting
            ))
        }

        if let stat = stats.makeRate26Plus {
            rows.append(StatRowModel(
                label: "Make Rate 26'+",
                values: [stat.timeframe: stat],
                displayType: .percentage,
                category: .putting
            ))
        }

        // Putts per GIR
        if let stat = stats.puttsPerGIR {
            rows.append(StatRowModel(
                label: "Putts/GIR",
                values: [stat.timeframe: stat],
                displayType: .number,
                category: .putting
            ))
        }

        // SG by Distance
        if let stat = stats.strokesGained3_4ft {
            rows.append(StatRowModel(
                label: "Strokes Gained Putting 3-4'",
                values: [stat.timeframe: stat],
                displayType: .strokesGained,
                category: .putting
            ))
        }

        if let stat = stats.strokesGained4_8ft {
            rows.append(StatRowModel(
                label: "Strokes Gained Putting 4-8'",
                values: [stat.timeframe: stat],
                displayType: .strokesGained,
                category: .putting
            ))
        }

        if let stat = stats.strokesGained8_10ft {
            rows.append(StatRowModel(
                label: "Strokes Gained Putting 8-10'",
                values: [stat.timeframe: stat],
                displayType: .strokesGained,
                category: .putting
            ))
        }

        if let stat = stats.strokesGained10_15ft {
            rows.append(StatRowModel(
                label: "Strokes Gained Putting 10-15'",
                values: [stat.timeframe: stat],
                displayType: .strokesGained,
                category: .putting
            ))
        }

        if let stat = stats.strokesGained15_20ft {
            rows.append(StatRowModel(
                label: "Strokes Gained Putting 15-20'",
                values: [stat.timeframe: stat],
                displayType: .strokesGained,
                category: .putting
            ))
        }

        if let stat = stats.strokesGained20_25ft {
            rows.append(StatRowModel(
                label: "Strokes Gained Putting 20-25'",
                values: [stat.timeframe: stat],
                displayType: .strokesGained,
                category: .putting
            ))
        }

        if let stat = stats.strokesGained25Plus {
            rows.append(StatRowModel(
                label: "Strokes Gained Putting 25'+",
                values: [stat.timeframe: stat],
                displayType: .strokesGained,
                category: .putting
            ))
        }

        return rows
    }
}
