import Foundation
import Combine
import CoreLocation

// MARK: - Strokes Gained View Model

final class StrokesGainedViewModel: ObservableObject {

    static let shared = StrokesGainedViewModel()

    // MARK: - Published Properties

    @Published private(set) var currentSession: RoundSession?
    @Published private(set) var currentSummary: RoundSummaryV2?
    @Published private(set) var allSummaries: [RoundSummaryV2] = []
    @Published private(set) var shotRows: [ShotRowModel] = []
    @Published private(set) var focusPoints: [InsightCard] = []
    @Published private(set) var trends: [TrendsCalculator.TrendData] = []

    @Published private(set) var isLoading = false
    @Published private(set) var error: String?

    // MARK: - Core Components

    private let stateDeriver: StateDeriver
    private let summaryBuilder: RoundSummaryBuilder
    private let insightGenerator: InsightGenerator
    private let trendsCalculator: TrendsCalculator
    private let persistenceManager: RoundPersistenceManager

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    private init() {
        self.stateDeriver = StateDeriver()
        self.summaryBuilder = RoundSummaryBuilder()
        self.insightGenerator = InsightGenerator()
        self.trendsCalculator = TrendsCalculator()
        self.persistenceManager = RoundPersistenceManager.shared

        loadSavedData()
    }

    // MARK: - Public Methods

    /// Load all saved round data
    func loadSavedData() {
        allSummaries = persistenceManager.loadAllSummaries()
        trends = trendsCalculator.calculateTrends(from: allSummaries)

        // Load most recent round if available
        if let latestSession = persistenceManager.loadAllRounds().first,
           latestSession.summary != nil,
           !(latestSession.summary?.sgByCategory.isEmpty ?? true) {
            currentSession = latestSession
            currentSummary = latestSession.summary
            updateShotRows()
            updateFocusPoints()
        } else {
            // Load demo data to showcase strokes gained feature
            loadDemoData()
        }
    }

    /// Start a new round session
    func startNewRound(courseName: String?, courseLayout: CourseLayout? = nil) {
        let session = RoundSession(courseName: courseName)
        currentSession = session

        if let layout = courseLayout {
            stateDeriver.setCourse(layout)
        }

        // Start location recording
        LocationRecorder.shared.startRecording()
    }

    /// Add a shot event from video
    func addShotEvent(_ event: ShotEvent) {
        guard var session = currentSession else { return }
        session.events.append(event)
        currentSession = session
    }

    /// Process all events and compute strokes gained
    func processRound(timebase: VideoSessionTimebase? = nil) {
        guard let session = currentSession else { return }

        isLoading = true

        // Derive shots from events
        let derivedShots = stateDeriver.deriveShots(from: session.events, timebase: timebase)

        // Build summary
        let summary = summaryBuilder.build(from: derivedShots, roundId: session.id, courseName: session.courseName)

        // Update session
        var updatedSession = session
        updatedSession.shots = derivedShots
        updatedSession.summary = summary

        currentSession = updatedSession
        currentSummary = summary

        // Update UI data
        updateShotRows()
        updateFocusPoints()

        // Persist
        try? persistenceManager.save(round: updatedSession)

        // Reload all data for trends
        allSummaries = persistenceManager.loadAllSummaries()
        trends = trendsCalculator.calculateTrends(from: allSummaries)

        isLoading = false
    }

    /// End current round
    func endRound() {
        LocationRecorder.shared.stopRecording()
        processRound()
    }

    // MARK: - Shot Queries

    /// Get shots for a specific category
    func shots(for category: SGCategory) -> [ShotRowModel] {
        shotRows.filter { row in
            self.category(for: row) == category
        }
    }

    /// Get shots for a specific hole
    func shots(for holeNumber: Int) -> [ShotRowModel] {
        shotRows.filter { $0.holeNumber == holeNumber }
    }

    /// Determine category for a shot row
    func category(for shot: ShotRowModel) -> SGCategory {
        if shot.startLie == .green {
            return .putting
        }
        if shot.startLie == .tee && shot.shotIndex == 1 {
            // Check if it's a par 3 tee shot (approach) or par 4/5 (OTT)
            if let startDist = Double(shot.startDistDisplay.replacingOccurrences(of: " yds", with: "").replacingOccurrences(of: " ft", with: "")),
               startDist > 200 {
                return .offTheTee
            }
            return .approach
        }
        if shot.startLie == .fringe || shot.startLie == .bunker {
            return .shortGame
        }
        if let dist = Double(shot.startDistDisplay.replacingOccurrences(of: " yds", with: "").replacingOccurrences(of: " ft", with: "")),
           dist <= 30 {
            return .shortGame
        }
        return .approach
    }

    /// Get best shots for a category
    func bestShots(for category: SGCategory) -> [ShotRowModel] {
        shots(for: category)
            .filter { $0.strokesGained != nil }
            .sorted { ($0.strokesGained ?? 0) > ($1.strokesGained ?? 0) }
    }

    /// Get worst shots for a category
    func worstShots(for category: SGCategory) -> [ShotRowModel] {
        shots(for: category)
            .filter { $0.strokesGained != nil }
            .sorted { ($0.strokesGained ?? 0) < ($1.strokesGained ?? 0) }
    }

    // MARK: - Private Methods

    private func updateShotRows() {
        guard let session = currentSession else {
            shotRows = []
            return
        }

        shotRows = session.shots.map { ShotRowModel(from: $0) }
    }

    private func updateFocusPoints() {
        guard let summary = currentSummary else {
            focusPoints = []
            return
        }

        focusPoints = insightGenerator.generateFocusPoints(from: summary)
    }

    // MARK: - Demo Data

    func loadDemoData() {
        // Generate mock demo round
        let demoSession = MockDataGenerator.generateDemoRound()
        currentSession = demoSession
        currentSummary = demoSession.summary

        if let summary = currentSummary {
            allSummaries = [summary]
            trends = trendsCalculator.calculateTrends(from: allSummaries)
        }

        updateShotRows()
        updateFocusPoints()
    }
}

// MARK: - Mock Data Generator

struct MockDataGenerator {

    static func generateDemoRound() -> RoundSession {
        var session = RoundSession(id: "demo-round", courseName: "Pebble Beach Golf Links")

        // Generate 18 holes worth of shots
        var allShots: [DerivedShot] = []
        var shotNumber = 0

        for holeNum in 1...18 {
            let holePar = [3, 4, 4, 4, 3, 5, 3, 4, 4, 4, 4, 3, 4, 5, 4, 3, 4, 5][holeNum - 1]
            let shotsThisHole = holePar + Int.random(in: -1...2)  // Score ±2 from par

            for shotIndex in 1...max(1, shotsThisHole) {
                shotNumber += 1
                var shot = DerivedShot(id: "demo-\(holeNum)-\(shotIndex)", shotNumber: shotIndex)

                shot.holeNumber = ProvenanceValue(auto: holeNum, confidence: 0.95, source: .derived)

                // Determine lie and distances based on shot index
                if shotIndex == 1 {
                    // Tee shot
                    shot.startState.lie = ProvenanceValue(auto: .tee, confidence: 0.95, source: .derived)
                    let holeYardage = Double([380, 502, 388, 327, 188, 513, 106, 428, 466, 495, 380, 202, 445, 573, 397, 403, 178, 543][holeNum - 1])
                    shot.startState.distanceToPin = ProvenanceValue(auto: holeYardage, confidence: 0.9, source: .gps)

                    // End state depends on shot quality
                    let quality = Double.random(in: 0...1)
                    if holePar == 3 {
                        // Par 3 tee shot
                        shot.category = .approach
                        let endDist = holeYardage * (1 - quality * 0.95)  // Better shot = closer
                        shot.endState.distanceToPin = ProvenanceValue(auto: endDist < 30 ? endDist * 3 : endDist, confidence: 0.85, source: .derived)
                        shot.endState.lie = ProvenanceValue(auto: endDist < 10 ? .green : (quality > 0.5 ? .fairway : .rough), confidence: 0.7, source: .derived)
                    } else {
                        // Par 4/5 tee shot
                        shot.category = .offTheTee
                        let driveDistance = 200 + quality * 100
                        let endDist = holeYardage - driveDistance
                        shot.endState.distanceToPin = ProvenanceValue(auto: max(50, endDist), confidence: 0.85, source: .derived)
                        shot.endState.lie = ProvenanceValue(auto: quality > 0.4 ? .fairway : .rough, confidence: 0.7, source: .derived)
                    }
                } else if shotIndex == shotsThisHole {
                    // Final putt
                    shot.startState.lie = ProvenanceValue(auto: .green, confidence: 0.95, source: .derived)
                    shot.startState.distanceToPin = ProvenanceValue(auto: Double.random(in: 2...8), confidence: 0.85, source: .derived)
                    shot.endState.distanceToPin = ProvenanceValue(auto: 0, confidence: 1.0, source: .derived)
                    shot.endState.lie = ProvenanceValue(auto: .green, confidence: 1.0, source: .derived)
                    shot.isHoled = true
                    shot.holedConfidence = 1.0
                    shot.category = .putting
                } else if shotIndex == shotsThisHole - 1 {
                    // Likely a putt or chip
                    let isOnGreen = Double.random(in: 0...1) > 0.3
                    if isOnGreen {
                        shot.startState.lie = ProvenanceValue(auto: .green, confidence: 0.9, source: .derived)
                        let puttLength = Double.random(in: 5...25)
                        shot.startState.distanceToPin = ProvenanceValue(auto: puttLength, confidence: 0.8, source: .gps)
                        shot.endState.distanceToPin = ProvenanceValue(auto: Double.random(in: 2...6), confidence: 0.8, source: .derived)
                        shot.endState.lie = ProvenanceValue(auto: .green, confidence: 0.9, source: .derived)
                        shot.category = .putting
                    } else {
                        shot.startState.lie = ProvenanceValue(auto: Bool.random() ? .fringe : .rough, confidence: 0.7, source: .derived)
                        shot.startState.distanceToPin = ProvenanceValue(auto: Double.random(in: 10...30), confidence: 0.75, source: .gps)
                        shot.endState.distanceToPin = ProvenanceValue(auto: Double.random(in: 3...12), confidence: 0.7, source: .derived)
                        shot.endState.lie = ProvenanceValue(auto: .green, confidence: 0.85, source: .derived)
                        shot.category = .shortGame
                    }
                } else {
                    // Approach or intermediate shot
                    let prevDist = allShots.last?.endState.distanceToPin.value ?? 150
                    shot.startState.lie = ProvenanceValue(auto: Bool.random() ? .fairway : .rough, confidence: 0.7, source: .derived)
                    shot.startState.distanceToPin = ProvenanceValue(auto: prevDist, confidence: 0.8, source: .gps)

                    let quality = Double.random(in: 0...1)
                    let shotDistance = min(prevDist * 0.7, 100 + quality * 50)
                    let endDist = max(5, prevDist - shotDistance)

                    if endDist < 30 {
                        shot.endState.lie = ProvenanceValue(auto: quality > 0.5 ? .green : .fringe, confidence: 0.7, source: .derived)
                        shot.endState.distanceToPin = ProvenanceValue(auto: endDist * (shot.endState.lie.value == .green ? 3 : 1), confidence: 0.75, source: .derived)
                        shot.category = prevDist > 30 ? .approach : .shortGame
                    } else {
                        shot.endState.lie = ProvenanceValue(auto: quality > 0.5 ? .fairway : .rough, confidence: 0.7, source: .derived)
                        shot.endState.distanceToPin = ProvenanceValue(auto: endDist, confidence: 0.75, source: .derived)
                        shot.category = .approach
                    }
                }

                // Set shot type based on category
                switch shot.category {
                case .offTheTee:
                    shot.shotType = ProvenanceValue(auto: .drive, confidence: 0.9, source: .derived)
                case .approach:
                    shot.shotType = ProvenanceValue(auto: .approach, confidence: 0.8, source: .derived)
                case .shortGame:
                    shot.shotType = ProvenanceValue(auto: shot.startState.lie.value == .bunker ? .bunkerShot : .chip, confidence: 0.7, source: .derived)
                case .putting:
                    shot.shotType = ProvenanceValue(auto: .putt, confidence: 0.95, source: .derived)
                case .none:
                    shot.shotType = ProvenanceValue(auto: .unknown, confidence: 0.5, source: .derived)
                }

                // Calculate expected strokes and SG
                shot.updateExpectedStrokes()
                let calculator = StrokesGainedCalculator()
                shot.strokesGained = calculator.calculate(shot: shot)

                // Set confidence
                shot.confidence = ShotConfidence(
                    holeConfidence: 0.9,
                    startLocationConfidence: Double.random(in: 0.7...0.95),
                    endLocationConfidence: Double.random(in: 0.65...0.9),
                    distanceConfidence: Double.random(in: 0.7...0.9),
                    lieConfidence: Double.random(in: 0.6...0.85),
                    shotTypeConfidence: Double.random(in: 0.75...0.95)
                )

                // Randomly flag some shots
                shot.isPenaltyLikely = Double.random(in: 0...1) < 0.05

                allShots.append(shot)
            }
        }

        session.shots = allShots

        // Build summary
        let builder = RoundSummaryBuilder()
        session.summary = builder.build(from: allShots, roundId: session.id, courseName: session.courseName)

        return session
    }

    /// Generate a sample course layout (Pebble Beach approximation)
    static func generateDemoCourse() -> CourseLayout {
        let holes: [HoleLocation] = [
            // Hole 1 - Par 4, 380 yards
            HoleLocation(
                holeNumber: 1,
                par: 4,
                teeLocation: CLLocationCoordinate2D(latitude: 36.5689, longitude: -121.9497),
                greenCenter: CLLocationCoordinate2D(latitude: 36.5673, longitude: -121.9485),
                pinLocation: nil,
                yardage: 380,
                greenRadius: 15
            ),
            // Simplified - add more holes as needed
        ]

        return CourseLayout(courseId: "pebble-beach", courseName: "Pebble Beach Golf Links", holes: holes)
    }
}
