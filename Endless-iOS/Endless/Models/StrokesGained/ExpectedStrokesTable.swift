import Foundation

// MARK: - Expected Strokes Provider Protocol

/// Protocol for providing expected strokes from a given position
protocol ExpectedStrokesProvider {
    /// Get expected strokes from a position
    /// - Parameters:
    ///   - distance: Distance to hole in yards (or feet for putting)
    ///   - lie: The current lie
    ///   - isPutt: Whether this is putting distance (in feet)
    /// - Returns: Expected strokes to hole out from this position
    func expectedStrokes(distance: Double, lie: Lie, isPutt: Bool) -> Double
}

// MARK: - Table-Based Expected Strokes Provider

/// PGA Tour-based expected strokes lookup tables
/// Data derived from PGA Tour ShotLink statistics
final class TableExpectedStrokesProvider: ExpectedStrokesProvider {

    static let shared = TableExpectedStrokesProvider()

    // MARK: - Putting Expected Strokes (distance in feet)

    /// Expected strokes for putting at various distances
    /// Based on PGA Tour make percentages converted to expected strokes
    private let puttingTable: [(maxFeet: Double, expectedStrokes: Double)] = [
        (1, 1.001),    // Tap-in
        (2, 1.009),
        (3, 1.04),
        (4, 1.13),
        (5, 1.23),
        (6, 1.33),
        (7, 1.42),
        (8, 1.50),
        (9, 1.56),
        (10, 1.61),
        (12, 1.70),
        (15, 1.78),
        (18, 1.84),
        (20, 1.87),
        (25, 1.92),
        (30, 1.96),
        (35, 1.98),
        (40, 2.00),
        (50, 2.04),
        (60, 2.08),
        (80, 2.14),
        (100, 2.20)
    ]

    // MARK: - Tee Shot Expected Strokes (distance in yards)

    /// Expected strokes from tee based on hole distance
    private let teeTable: [(maxYards: Double, expectedStrokes: Double)] = [
        (150, 2.92),   // Par 3
        (175, 2.99),
        (200, 3.05),
        (225, 3.17),
        (250, 3.25),   // Short par 4
        (275, 3.45),
        (300, 3.65),
        (325, 3.75),
        (350, 3.85),
        (375, 3.92),
        (400, 4.08),   // Par 4
        (425, 4.17),
        (450, 4.32),
        (475, 4.45),
        (500, 4.55),   // Long par 4 / Short par 5
        (525, 4.65),
        (550, 4.75),
        (575, 4.85),
        (600, 4.95),
        (650, 5.10)    // Long par 5
    ]

    // MARK: - Fairway Expected Strokes (distance in yards)

    private let fairwayTable: [(maxYards: Double, expectedStrokes: Double)] = [
        (20, 2.40),
        (30, 2.45),
        (40, 2.52),
        (50, 2.60),
        (60, 2.68),
        (70, 2.75),
        (80, 2.82),
        (90, 2.88),
        (100, 2.92),
        (110, 2.96),
        (120, 2.99),
        (130, 3.02),
        (140, 3.05),
        (150, 3.08),
        (160, 3.12),
        (170, 3.17),
        (180, 3.22),
        (190, 3.28),
        (200, 3.35),
        (210, 3.42),
        (220, 3.50),
        (230, 3.58),
        (240, 3.68),
        (250, 3.78),
        (260, 3.88),
        (280, 4.00),
        (300, 4.15)
    ]

    // MARK: - Rough Expected Strokes

    private let roughTable: [(maxYards: Double, expectedStrokes: Double)] = [
        (20, 2.55),
        (30, 2.62),
        (40, 2.70),
        (50, 2.78),
        (60, 2.85),
        (70, 2.92),
        (80, 2.98),
        (90, 3.05),
        (100, 3.10),
        (110, 3.15),
        (120, 3.20),
        (130, 3.25),
        (140, 3.30),
        (150, 3.36),
        (160, 3.42),
        (170, 3.50),
        (180, 3.58),
        (190, 3.67),
        (200, 3.75),
        (220, 3.92),
        (240, 4.10),
        (260, 4.28),
        (280, 4.45)
    ]

    // MARK: - Bunker Expected Strokes

    private let bunkerTable: [(maxYards: Double, expectedStrokes: Double)] = [
        (10, 2.43),    // Greenside bunker
        (20, 2.55),
        (30, 2.70),
        (40, 2.85),
        (50, 3.00),
        (60, 3.15),
        (70, 3.30),
        (80, 3.45),
        (100, 3.65),
        (120, 3.85),
        (150, 4.10)    // Fairway bunker
    ]

    // MARK: - Fringe/Around Green Expected Strokes

    private let fringeTable: [(maxYards: Double, expectedStrokes: Double)] = [
        (3, 2.10),
        (5, 2.20),
        (10, 2.35),
        (15, 2.45),
        (20, 2.55),
        (25, 2.62),
        (30, 2.70)
    ]

    // MARK: - Recovery Expected Strokes

    private let recoveryTable: [(maxYards: Double, expectedStrokes: Double)] = [
        (50, 3.20),
        (100, 3.50),
        (150, 3.80),
        (200, 4.10),
        (250, 4.40)
    ]

    // MARK: - Lookup Methods

    func expectedStrokes(distance: Double, lie: Lie, isPutt: Bool) -> Double {
        if isPutt || lie == .green {
            return lookupPutting(distanceFeet: distance)
        }

        switch lie {
        case .tee:
            return lookupTee(distanceYards: distance)
        case .fairway:
            return lookupFairway(distanceYards: distance)
        case .rough, .deepRough:
            return lookupRough(distanceYards: distance)
        case .bunker:
            return lookupBunker(distanceYards: distance)
        case .fringe:
            return lookupFringe(distanceYards: distance)
        case .recovery:
            return lookupRecovery(distanceYards: distance)
        case .green:
            return lookupPutting(distanceFeet: distance * 3)  // Convert to feet
        case .unknown:
            // Default to fairway as middle ground
            return lookupFairway(distanceYards: distance)
        }
    }

    private func lookupPutting(distanceFeet: Double) -> Double {
        interpolate(distance: distanceFeet, in: puttingTable)
    }

    private func lookupTee(distanceYards: Double) -> Double {
        interpolate(distance: distanceYards, in: teeTable)
    }

    private func lookupFairway(distanceYards: Double) -> Double {
        interpolate(distance: distanceYards, in: fairwayTable)
    }

    private func lookupRough(distanceYards: Double) -> Double {
        interpolate(distance: distanceYards, in: roughTable)
    }

    private func lookupBunker(distanceYards: Double) -> Double {
        interpolate(distance: distanceYards, in: bunkerTable)
    }

    private func lookupFringe(distanceYards: Double) -> Double {
        interpolate(distance: distanceYards, in: fringeTable)
    }

    private func lookupRecovery(distanceYards: Double) -> Double {
        interpolate(distance: distanceYards, in: recoveryTable)
    }

    /// Linear interpolation between table entries
    private func interpolate(distance: Double, in table: [(maxDist: Double, expected: Double)]) -> Double {
        guard !table.isEmpty else { return 3.5 }  // Safe default

        // Handle below minimum
        if distance <= table[0].maxDist {
            return table[0].expected
        }

        // Handle above maximum
        if distance >= table[table.count - 1].maxDist {
            // Extrapolate slightly above max
            let last = table[table.count - 1]
            let secondLast = table[table.count - 2]
            let slope = (last.expected - secondLast.expected) / (last.maxDist - secondLast.maxDist)
            return last.expected + slope * (distance - last.maxDist)
        }

        // Find bracket and interpolate
        for i in 1..<table.count {
            if distance <= table[i].maxDist {
                let lower = table[i - 1]
                let upper = table[i]
                let ratio = (distance - lower.maxDist) / (upper.maxDist - lower.maxDist)
                return lower.expected + ratio * (upper.expected - lower.expected)
            }
        }

        return table[table.count - 1].expected
    }
}

// MARK: - Strokes Gained Calculator

/// Core calculator for strokes gained values
struct StrokesGainedCalculator {

    let provider: ExpectedStrokesProvider

    init(provider: ExpectedStrokesProvider = TableExpectedStrokesProvider.shared) {
        self.provider = provider
    }

    /// Calculate strokes gained for a single shot
    /// SG = Expected(start) - Expected(end) - 1 - penalty_strokes
    func calculate(shot: DerivedShot) -> Double? {
        guard let startDistance = shot.startState.distanceToPin.value,
              let endDistance = shot.endState.distanceToPin.value,
              let startLie = shot.startState.lie.value,
              let endLie = shot.endState.lie.value else {
            return nil
        }

        let isPuttStart = startLie == .green
        let isPuttEnd = endLie == .green || shot.isHoled

        // Get expected strokes
        let startExpected: Double
        let endExpected: Double

        if isPuttStart {
            // Putting: distances in feet
            startExpected = provider.expectedStrokes(distance: startDistance, lie: startLie, isPutt: true)
        } else {
            // Full shot: distances in yards
            startExpected = provider.expectedStrokes(distance: startDistance, lie: startLie, isPutt: false)
        }

        if shot.isHoled {
            endExpected = 0
        } else if isPuttEnd {
            // Ended on green: end distance in feet
            endExpected = provider.expectedStrokes(distance: endDistance, lie: endLie, isPutt: true)
        } else {
            // Ended off green: end distance in yards
            endExpected = provider.expectedStrokes(distance: endDistance, lie: endLie, isPutt: false)
        }

        // SG = startExpected - endExpected - strokesTaken
        let strokesTaken = 1.0 + Double(shot.penaltyStrokes)
        let sg = startExpected - endExpected - strokesTaken

        return sg
    }

    /// Determine the SG category for a shot
    func category(for shot: DerivedShot) -> SGCategory {
        guard let lie = shot.startState.lie.value,
              let distance = shot.startState.distanceToPin.value else {
            return .approach  // Default
        }

        // Putting: on the green
        if lie == .green {
            return .putting
        }

        // Short game: within 30 yards of green and not a tee shot
        if distance <= 30 && lie != .tee {
            return .shortGame
        }

        // Off the tee: tee shots on par 4s and par 5s
        if lie == .tee && shot.shotNumber == 1 {
            // Could check par here if available
            // For now, assume first shot from tee on longer holes is OTT
            if distance > 200 {
                return .offTheTee
            }
        }

        // Everything else is approach
        return .approach
    }
}

// MARK: - Expected Strokes Extensions

extension DerivedShot {
    /// Update expected strokes values based on current states
    mutating func updateExpectedStrokes(provider: ExpectedStrokesProvider = TableExpectedStrokesProvider.shared) {
        if let startDistance = startState.distanceToPin.value,
           let startLie = startState.lie.value {
            let isPutt = startLie == .green
            startState.expectedStrokes = provider.expectedStrokes(distance: startDistance, lie: startLie, isPutt: isPutt)
        }

        if isHoled {
            endState.expectedStrokes = 0
        } else if let endDistance = endState.distanceToPin.value,
                  let endLie = endState.lie.value {
            let isPutt = endLie == .green
            endState.expectedStrokes = provider.expectedStrokes(distance: endDistance, lie: endLie, isPutt: isPutt)
        }
    }
}
