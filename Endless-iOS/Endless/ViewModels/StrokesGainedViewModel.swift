import Foundation
import Combine
import SwiftUI

// MARK: - Strokes Gained View Model

final class StrokesGainedViewModel: ObservableObject {

    static let shared = StrokesGainedViewModel()

    // MARK: - Published Properties

    @Published private(set) var currentSummary: RoundSummary?
    @Published private(set) var allSummaries: [RoundSummary] = []
    @Published private(set) var selectedTimeframe: StatTimeframe = .season

    @Published private(set) var isLoading = false
    @Published private(set) var error: String?

    // Category-specific stat rows
    @Published private(set) var scoringRows: [StatRowModel] = []
    @Published private(set) var teeRows: [StatRowModel] = []
    @Published private(set) var approachRows: [StatRowModel] = []
    @Published private(set) var shortGameRows: [StatRowModel] = []
    @Published private(set) var puttingRows: [StatRowModel] = []

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    private init() {
        loadDemoData()
    }

    // MARK: - Public Methods

    func setTimeframe(_ timeframe: StatTimeframe) {
        selectedTimeframe = timeframe
        // In a real app, this would reload stats for the selected timeframe
    }

    func stats(for category: SGCategory) -> [StatRowModel] {
        switch category {
        case .offTheTee: return teeRows
        case .approach: return approachRows
        case .shortGame: return shortGameRows
        case .putting: return puttingRows
        }
    }

    func sgValue(for category: SGCategory) -> Double {
        currentSummary?.sg(for: category) ?? 0
    }

    // MARK: - Demo Data

    func loadDemoData() {
        // Generate demo statistics matching the screenshot format

        // SCORING Stats
        var scoring = ScoringStatistics()
        scoring.scoringAverage = StatValue(value: 74.18, sampleSize: 11, timeframe: .season)
        scoring.strokesGainedPutting = StatValue(value: -1.81, sampleSize: 207, timeframe: .season)
        scoring.par3Scoring = StatValue(value: 3.17, sampleSize: 46, timeframe: .season)
        scoring.par4Scoring = StatValue(value: 4.21, sampleSize: 115, timeframe: .season)
        scoring.par5Scoring = StatValue(value: 4.85, sampleSize: 46, timeframe: .season)
        scoring.par3GIR = StatValue(value: 0.6087, sampleSize: 46, timeframe: .season)
        scoring.par4GIR = StatValue(value: 0.6522, sampleSize: 115, timeframe: .season)
        scoring.par5GIR = StatValue(value: 0.7826, sampleSize: 46, timeframe: .season)
        scoring.eaglesPerRound = StatValue(value: 0.09, sampleSize: 11, timeframe: .season)
        scoring.birdiesPerRound = StatValue(value: 2.26, sampleSize: 11, timeframe: .season)
        scoring.bogeysPerRound = StatValue(value: 3.74, sampleSize: 11, timeframe: .season)
        scoring.doubleBogeyPlusPerRound = StatValue(value: 0.44, sampleSize: 11, timeframe: .season)
        scoring.doubleBogeysPerRound = StatValue(value: 0.44, sampleSize: 11, timeframe: .season)
        scoring.birdiesToBogeys = StatValue(value: 0.56, sampleSize: 207, timeframe: .season)

        scoringRows = CategoryStatsBuilder.buildScoringRows(from: scoring)

        // TEE Stats
        var tee = TeeStatistics()
        tee.fairwayHitPercentage = StatValue(value: 0.5217, sampleSize: 161, timeframe: .season)
        tee.driverSelectionPercentage = StatValue(value: 0.4286, sampleSize: 161, timeframe: .season)
        tee.driverFairwaysHitPercentage = StatValue(value: 0.4493, sampleSize: 69, timeframe: .season)
        tee.teeShotLeftPercentage = StatValue(value: 0.1553, sampleSize: 161, timeframe: .season)
        tee.teeShotRightPercentage = StatValue(value: 0.323, sampleSize: 161, timeframe: .season)
        tee.teeShotInTreesPercentage = StatValue(value: 0.0683, sampleSize: 161, timeframe: .season)
        tee.teeShotInSandPercentage = StatValue(value: 0.0559, sampleSize: 161, timeframe: .season)
        tee.holesWithPenaltiesPercentage = StatValue(value: 0.0062, sampleSize: 161, timeframe: .season)
        tee.strokesGainedDrivingPerRound = StatValue(value: -2.39, sampleSize: 11, timeframe: .season)
        tee.penaltyRateOffTee = StatValue(value: 0.0062, sampleSize: 161, timeframe: .season)

        teeRows = CategoryStatsBuilder.buildTeeRows(from: tee)

        // APPROACH Stats
        var approach = ApproachStatistics()
        approach.totalGIR = StatValue(value: 0.6715, sampleSize: 207, timeframe: .season)
        approach.gir75_100Fairway = StatValue(value: 0.9474, sampleSize: 19, timeframe: .season)
        approach.gir101_150Fairway = StatValue(value: 0.7667, sampleSize: 30, timeframe: .season)
        approach.gir151_200Fairway = StatValue(value: 0.6042, sampleSize: 48, timeframe: .season)
        approach.gir201_230Fairway = StatValue(value: 0.4667, sampleSize: 15, timeframe: .season)
        approach.girFairwayBunker = StatValue(value: 0.3333, sampleSize: 9, timeframe: .season)
        approach.girOtherThanFairway = StatValue(value: 0.5584, sampleSize: 77, timeframe: .season)
        approach.leftRoughGIR = StatValue(value: 0.60, sampleSize: 25, timeframe: .season)
        approach.rightRoughGIR = StatValue(value: 0.5385, sampleSize: 52, timeframe: .season)
        approach.proximity25_75Fairway = StatValue(value: 13.67, sampleSize: 6, timeframe: .season)
        approach.proximity75_100Fairway = StatValue(value: 20.31, sampleSize: 16, timeframe: .season)
        approach.proximity100_150Fairway = StatValue(value: 22.0, sampleSize: 19, timeframe: .season)
        approach.scoringAvg75_100Fairway = StatValue(value: 3.0, sampleSize: 19, timeframe: .season)
        approach.scoringAvg101_150Fairway = StatValue(value: 3.04, sampleSize: 25, timeframe: .season)
        approach.scoringAvg151_200Fairway = StatValue(value: 3.27, sampleSize: 15, timeframe: .season)
        approach.scoringAvg201_250Fairway = StatValue(value: 3.6, sampleSize: 15, timeframe: .season)
        approach.strokesGainedApproachPerRound = StatValue(value: -0.97, sampleSize: 11, timeframe: .season)
        approach.strokesGained50_75yds = StatValue(value: 0.01, sampleSize: 16, timeframe: .season)
        approach.strokesGained76_100yds = StatValue(value: 0.04, sampleSize: 26, timeframe: .season)
        approach.strokesGained101_150yds = StatValue(value: -0.08, sampleSize: 44, timeframe: .season)
        approach.strokesGained151_200yds = StatValue(value: -0.02, sampleSize: 55, timeframe: .season)
        approach.strokesGained201_230yds = StatValue(value: -0.23, sampleSize: 18, timeframe: .season)

        approachRows = CategoryStatsBuilder.buildApproachRows(from: approach)

        // SHORT GAME Stats
        var shortGame = ShortGameStatistics()
        shortGame.savePercentage = StatValue(value: 0.4568, sampleSize: 81, timeframe: .season)
        shortGame.roughSavePercentage = StatValue(value: 0.4651, sampleSize: 43, timeframe: .season)
        shortGame.sandSavePercentage = StatValue(value: 0.50, sampleSize: 16, timeframe: .season)
        shortGame.fairwaySavePercentage = StatValue(value: 0.4444, sampleSize: 18, timeframe: .season)
        shortGame.saveLessThan10yds = StatValue(value: 1.0, sampleSize: 3, timeframe: .season)
        shortGame.save10_20yds = StatValue(value: 0.6774, sampleSize: 31, timeframe: .season)
        shortGame.save20_30yds = StatValue(value: 0.3235, sampleSize: 34, timeframe: .season)
        shortGame.sandSave10_20yds = StatValue(value: 0.7143, sampleSize: 7, timeframe: .season)
        shortGame.sandSave20_30yds = StatValue(value: 0.3333, sampleSize: 9, timeframe: .season)
        shortGame.proximityToHoleFromSand = StatValue(value: 13.62, sampleSize: 16, timeframe: .season)
        shortGame.proximityToHoleFromRough = StatValue(value: 11.49, sampleSize: 43, timeframe: .season)
        shortGame.strokesGainedPuttingOnSaves = StatValue(value: 0.07, sampleSize: 81, timeframe: .season)
        shortGame.twoChipsPerRound = StatValue(value: 0.61, sampleSize: 11, timeframe: .season)
        shortGame.strokesGainedShortGamePerRound = StatValue(value: 0.14, sampleSize: 11, timeframe: .season)
        shortGame.strokesGained0_10yds = StatValue(value: 0.2, sampleSize: 7, timeframe: .season)
        shortGame.strokesGained11_20yds = StatValue(value: 0.1, sampleSize: 34, timeframe: .season)
        shortGame.strokesGained21_30yds = StatValue(value: -0.16, sampleSize: 26, timeframe: .season)
        shortGame.strokesGained31_40yds = StatValue(value: 0.25, sampleSize: 3, timeframe: .season)
        shortGame.strokesGained41_50yds = StatValue(value: 0.04, sampleSize: 6, timeframe: .season)
        shortGame.nonGIRParOrBetterRate = StatValue(value: 0.4706, sampleSize: 68, timeframe: .season)

        shortGameRows = CategoryStatsBuilder.buildShortGameRows(from: shortGame)

        // PUTTING Stats
        var putting = PuttingStatistics()
        putting.strokesGainedPutting = StatValue(value: -1.81, sampleSize: 207, timeframe: .season)
        putting.total3PuttAvoidance = StatValue(value: 0.0637, sampleSize: 204, timeframe: .season)
        putting.puttingSpeedRatio = StatValue(value: 2.15, sampleSize: 118, timeframe: .season)
        putting.makeRate3_4ft = StatValue(value: 0.83, sampleSize: 30, timeframe: .season)
        putting.makeRate5_8ft = StatValue(value: 0.56, sampleSize: 41, timeframe: .season)
        putting.makeRate9_10ft = StatValue(value: 0.28, sampleSize: 14, timeframe: .season)
        putting.makeRate11_15ft = StatValue(value: 0.11, sampleSize: 35, timeframe: .season)
        putting.makeRate16_20ft = StatValue(value: 0.17, sampleSize: 42, timeframe: .season)
        putting.makeRate21_25ft = StatValue(value: 0.12, sampleSize: 17, timeframe: .season)
        putting.makeRate26Plus = StatValue(value: 0.04, sampleSize: 49, timeframe: .season)
        putting.leaveShort5_10ft = StatValue(value: 0.29, sampleSize: 28, timeframe: .season)
        putting.leaveShort11_15ft = StatValue(value: 0.71, sampleSize: 31, timeframe: .season)
        putting.leaveShort16_20ft = StatValue(value: 0.63, sampleSize: 35, timeframe: .season)
        putting.leaveShort21_30ft = StatValue(value: 0.70, sampleSize: 33, timeframe: .season)
        putting.leaveShort31Plus = StatValue(value: 0.79, sampleSize: 29, timeframe: .season)
        putting.threePuttAvoidance5_10ft = StatValue(value: 0.0294, sampleSize: 34, timeframe: .season)
        putting.threePuttAvoidance11_20ft = StatValue(value: 0.0, sampleSize: 73, timeframe: .season)
        putting.threePuttAvoidance21_30ft = StatValue(value: 0.1389, sampleSize: 36, timeframe: .season)
        putting.threePuttAvoidance31Plus = StatValue(value: 0.2333, sampleSize: 30, timeframe: .season)
        putting.puttsPerGIR = StatValue(value: 1.94, sampleSize: 139, timeframe: .season)
        putting.strokesGained3_4ft = StatValue(value: -0.09, sampleSize: 30, timeframe: .season)
        putting.strokesGained4_8ft = StatValue(value: -0.09, sampleSize: 53, timeframe: .season)
        putting.strokesGained8_10ft = StatValue(value: -0.10, sampleSize: 22, timeframe: .season)
        putting.strokesGained10_15ft = StatValue(value: -0.15, sampleSize: 41, timeframe: .season)
        putting.strokesGained15_20ft = StatValue(value: -0.07, sampleSize: 58, timeframe: .season)
        putting.strokesGained20_25ft = StatValue(value: -0.07, sampleSize: 36, timeframe: .season)
        putting.strokesGained25Plus = StatValue(value: -0.10, sampleSize: 60, timeframe: .season)
        putting.strokesGained1stPuttOver20ft = StatValue(value: -0.08, sampleSize: 85, timeframe: .season)
        putting.strokesGained1stPuttOver20ftPerRound = StatValue(value: -0.63, sampleSize: 11, timeframe: .season)
        putting.firstPuttPerformance = StatValue(value: 0.50, sampleSize: 30, timeframe: .season)

        puttingRows = CategoryStatsBuilder.buildPuttingRows(from: putting)

        // Create round summary
        var summary = RoundSummary(courseName: "Demo Course")
        summary.sgOffTheTee = -2.39
        summary.sgApproach = -0.97
        summary.sgShortGame = 0.14
        summary.sgPutting = -1.81
        summary.totalStrokesGained = summary.sgOffTheTee + summary.sgApproach + summary.sgShortGame + summary.sgPutting
        summary.scoringStats = scoring
        summary.teeStats = tee
        summary.approachStats = approach
        summary.shortGameStats = shortGame
        summary.puttingStats = putting

        currentSummary = summary
        allSummaries = [summary]
    }
}
