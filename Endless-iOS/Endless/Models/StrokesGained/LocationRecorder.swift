import Foundation
import CoreLocation
import Combine

// MARK: - Location Recorder

/// Records GPS samples during a round for shot position tracking
final class LocationRecorder: NSObject, ObservableObject {

    static let shared = LocationRecorder()

    // MARK: - Published Properties

    @Published private(set) var isRecording = false
    @Published private(set) var samples: [LocationSample] = []
    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined

    // MARK: - Configuration

    /// Window size for GPS smoothing (seconds)
    var smoothingWindow: TimeInterval = 5.0

    /// Minimum accuracy to accept samples (meters)
    var minimumAccuracy: CLLocationAccuracy = 50.0

    /// Sample interval (seconds)
    var sampleInterval: TimeInterval = 1.0

    // MARK: - Private Properties

    private let locationManager = CLLocationManager()
    private var lastSampleTime: Date?
    private let processingQueue = DispatchQueue(label: "com.endless.locationRecorder", qos: .utility)

    // MARK: - Initialization

    private override init() {
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1.0  // meters
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = false

        // Check current authorization
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Authorization

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - Recording Control

    func startRecording() {
        guard !isRecording else { return }

        samples.removeAll()
        lastSampleTime = nil
        isRecording = true

        locationManager.startUpdatingLocation()
    }

    func stopRecording() {
        isRecording = false
        locationManager.stopUpdatingLocation()
    }

    func clearSamples() {
        samples.removeAll()
    }

    // MARK: - GPS Smoothing

    /// Get a smoothed location for a given timestamp
    /// Uses a windowed median approach with accuracy weighting
    func smoothedLocation(at timestamp: Date, window: TimeInterval? = nil) -> SmoothedLocation? {
        let windowSize = window ?? smoothingWindow
        let halfWindow = windowSize / 2.0

        // Gather samples within window
        let windowSamples = samples.filter { sample in
            let delta = abs(sample.timestamp.timeIntervalSince(timestamp))
            return delta <= halfWindow
        }

        guard !windowSamples.isEmpty else {
            return nil
        }

        // Calculate weighted average based on accuracy and time proximity
        var totalWeight: Double = 0
        var weightedLat: Double = 0
        var weightedLon: Double = 0
        var weightedAlt: Double = 0
        var hasAltitude = false
        var flags: [String] = []

        for sample in windowSamples {
            // Weight by accuracy (lower = better)
            let accuracyWeight = 1.0 / max(sample.horizontalAccuracy, 1.0)

            // Weight by time proximity
            let timeDelta = abs(sample.timestamp.timeIntervalSince(timestamp))
            let timeWeight = 1.0 - (timeDelta / halfWindow)

            let weight = accuracyWeight * timeWeight

            weightedLat += sample.latitude * weight
            weightedLon += sample.longitude * weight

            if let alt = sample.altitude {
                weightedAlt += alt * weight
                hasAltitude = true
            }

            totalWeight += weight
        }

        guard totalWeight > 0 else {
            return nil
        }

        let avgLat = weightedLat / totalWeight
        let avgLon = weightedLon / totalWeight
        let avgAlt = hasAltitude ? weightedAlt / totalWeight : nil

        // Calculate average accuracy
        let avgAccuracy = windowSamples.reduce(0.0) { $0 + $1.horizontalAccuracy } / Double(windowSamples.count)

        // Calculate confidence based on sample count and accuracy
        let sampleCountFactor = min(Double(windowSamples.count) / 5.0, 1.0)  // Max benefit at 5+ samples
        let accuracyFactor = max(0, 1.0 - (avgAccuracy / 30.0))  // 0-30m range
        let confidence = (sampleCountFactor * 0.4 + accuracyFactor * 0.6)

        // Add flags
        if windowSamples.count < 3 {
            flags.append("low_sample_count")
        }
        if avgAccuracy > 15 {
            flags.append("moderate_accuracy")
        }
        if avgAccuracy > 30 {
            flags.append("poor_accuracy")
        }

        return SmoothedLocation(
            coordinate: CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon),
            altitude: avgAlt,
            confidence: confidence,
            sampleCount: windowSamples.count,
            avgAccuracy: avgAccuracy,
            flags: flags
        )
    }

    /// Get the nearest sample to a timestamp
    func nearestSample(to timestamp: Date) -> LocationSample? {
        samples.min(by: { abs($0.timestamp.timeIntervalSince(timestamp)) < abs($1.timestamp.timeIntervalSince(timestamp)) })
    }

    /// Get samples within a time range
    func samples(from startTime: Date, to endTime: Date) -> [LocationSample] {
        samples.filter { $0.timestamp >= startTime && $0.timestamp <= endTime }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationRecorder: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isRecording else { return }

        for location in locations {
            // Filter by accuracy
            guard location.horizontalAccuracy > 0,
                  location.horizontalAccuracy <= minimumAccuracy else {
                continue
            }

            // Rate limit samples
            if let lastTime = lastSampleTime,
               location.timestamp.timeIntervalSince(lastTime) < sampleInterval {
                continue
            }

            let sample = LocationSample(from: location)

            DispatchQueue.main.async {
                self.samples.append(sample)
                self.currentLocation = location
                self.lastSampleTime = location.timestamp
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationRecorder error: \(error.localizedDescription)")
    }
}

// MARK: - Hole Resolver

/// Determines which hole a shot was played on using GPS and hysteresis
final class HoleResolver {

    private var courseLayout: CourseLayout?
    private var currentHoleNumber: Int?
    private var holeTransitionThreshold: Double = 30.0  // yards to be "near" a tee

    func setCourse(_ layout: CourseLayout) {
        self.courseLayout = layout
        self.currentHoleNumber = nil
    }

    /// Resolve hole number for a location
    func resolveHole(at coordinate: CLLocationCoordinate2D, timestamp: Date) -> (holeNumber: Int, confidence: Double)? {
        guard let layout = courseLayout else { return nil }

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        // Find nearest tee
        var nearestHole: Int?
        var nearestTeeDistance: Double = .infinity

        for hole in layout.holes {
            let tee = CLLocation(latitude: hole.teeLocation.latitude, longitude: hole.teeLocation.longitude)
            let distance = location.distance(from: tee) * 1.09361  // meters to yards

            if distance < nearestTeeDistance {
                nearestTeeDistance = distance
                nearestHole = hole.holeNumber
            }
        }

        guard let hole = nearestHole else { return nil }

        // Apply hysteresis: stick with current hole unless clearly at next tee
        if let current = currentHoleNumber {
            // If we're near the current hole's green/next tee, consider transition
            if nearestTeeDistance < holeTransitionThreshold && hole != current {
                // Transitioning to new hole
                currentHoleNumber = hole
                return (hole, 0.9)
            }

            // Otherwise stick with current
            return (current, 0.8)
        }

        // First hole assignment
        if nearestTeeDistance < 50 {
            currentHoleNumber = hole
            return (hole, 0.85)
        }

        return (hole, 0.5)  // Far from any tee
    }

    /// Reset for a new round
    func reset() {
        currentHoleNumber = nil
    }
}

// MARK: - Lie Assist

/// Assists with lie inference using GPS-based heuristics
final class LieAssist {

    private var courseLayout: CourseLayout?

    func setCourse(_ layout: CourseLayout) {
        self.courseLayout = layout
    }

    /// Infer lie from position and context
    func inferLie(
        at coordinate: CLLocationCoordinate2D,
        holeNumber: Int?,
        shotNumber: Int,
        shotType: ShotType?,
        distanceToPin: Double?,
        motionStability: Double?
    ) -> (lie: Lie, confidence: Double, reasons: [String]) {

        var reasons: [String] = []
        var confidence: Double = 0.3  // Base confidence

        // If we have shot type hint
        if let type = shotType {
            switch type {
            case .putt:
                reasons.append("shot_type_putt")
                return (.green, 0.9, reasons)
            case .drive:
                if shotNumber == 1 {
                    reasons.append("first_shot_drive")
                    return (.tee, 0.95, reasons)
                }
            case .bunkerShot:
                reasons.append("shot_type_bunker")
                return (.bunker, 0.85, reasons)
            default:
                break
            }
        }

        // First shot is from tee
        if shotNumber == 1 {
            reasons.append("first_shot_of_hole")
            return (.tee, 0.9, reasons)
        }

        // Check if on green using course layout
        if let layout = courseLayout,
           let holeNum = holeNumber,
           let hole = layout.hole(number: holeNum) {

            if hole.isOnGreen(coordinate: coordinate) {
                reasons.append("within_green_radius")
                confidence = 0.85

                // Motion stability can confirm putting stance
                if let stability = motionStability, stability < 0.2 {
                    reasons.append("stable_putting_motion")
                    confidence = 0.92
                }

                return (.green, confidence, reasons)
            }

            // Check distance to pin for fringe
            let distYards = hole.distanceToPin(from: coordinate)
            if distYards <= hole.greenRadius + 5 {  // Just off the green
                reasons.append("near_green_edge")
                return (.fringe, 0.7, reasons)
            }
        }

        // Use distance as heuristic
        if let dist = distanceToPin {
            if dist <= 3 {  // 3 feet or less = likely on green
                reasons.append("very_close_to_pin")
                return (.green, 0.75, reasons)
            }
            if dist <= 30 && shotNumber > 1 {  // 30 yards = around the green
                reasons.append("short_distance_to_pin")
                return (.fringe, 0.5, reasons)  // Could be fringe, rough, or fairway
            }
        }

        // Default to fairway with low confidence
        reasons.append("default_fairway_assumption")
        return (.fairway, 0.4, reasons)
    }
}

// MARK: - State Deriver

/// Derives complete shot states from events and location data
final class StateDeriver {

    private let locationRecorder: LocationRecorder
    private let holeResolver: HoleResolver
    private let lieAssist: LieAssist
    private let expectedStrokesProvider: ExpectedStrokesProvider

    private var courseLayout: CourseLayout?
    private var poseProvider: PoseProvider = NullPoseProvider()

    init(
        locationRecorder: LocationRecorder = .shared,
        holeResolver: HoleResolver = HoleResolver(),
        lieAssist: LieAssist = LieAssist(),
        expectedStrokesProvider: ExpectedStrokesProvider = TableExpectedStrokesProvider.shared
    ) {
        self.locationRecorder = locationRecorder
        self.holeResolver = holeResolver
        self.lieAssist = lieAssist
        self.expectedStrokesProvider = expectedStrokesProvider
    }

    func setCourse(_ layout: CourseLayout) {
        self.courseLayout = layout
        holeResolver.setCourse(layout)
        lieAssist.setCourse(layout)
    }

    func setPoseProvider(_ provider: PoseProvider) {
        self.poseProvider = provider
    }

    /// Derive shots from a sequence of events
    /// Implements "end state = next shot start" logic
    func deriveShots(from events: [ShotEvent], timebase: VideoSessionTimebase?) -> [DerivedShot] {
        guard !events.isEmpty else { return [] }

        var derivedShots: [DerivedShot] = []

        // First pass: standardize event times
        var standardizedEvents = events
        if let tb = timebase {
            for i in 0..<standardizedEvents.count {
                tb.standardizeEventDate(for: &standardizedEvents[i])
            }
        }

        // Sort by time
        let sortedEvents = standardizedEvents.sorted {
            ($0.eventDate ?? Date.distantPast) < ($1.eventDate ?? Date.distantPast)
        }

        // Second pass: derive shots
        for (index, event) in sortedEvents.enumerated() {
            var shot = DerivedShot(id: UUID().uuidString, shotNumber: index + 1)
            shot.eventId = event.id
            shot.event = event
            shot.clipStartSeconds = event.clipStartSeconds
            shot.impactSeconds = event.impactSeconds
            shot.clipEndSeconds = event.clipEndSeconds

            // Get event time
            guard let eventTime = event.eventDate else { continue }

            // Derive start state from this shot's position
            deriveStartState(for: &shot, at: eventTime, shotNumber: index + 1)

            // Derive end state from NEXT shot's start (if on same hole)
            if index + 1 < sortedEvents.count {
                let nextEvent = sortedEvents[index + 1]
                if let nextTime = nextEvent.eventDate {
                    deriveEndStateFromNextShot(for: &shot, nextEventTime: nextTime, currentShotNumber: index + 1)
                }
            } else {
                // Last shot: use clip end or fallback
                deriveEndStateFallback(for: &shot, eventTime: eventTime)
            }

            // Classify shot type and category
            classifyShot(&shot)

            // Calculate strokes gained
            let calculator = StrokesGainedCalculator(provider: expectedStrokesProvider)
            shot.strokesGained = calculator.calculate(shot: shot)
            shot.category = calculator.category(for: shot)

            // Update expected strokes
            shot.updateExpectedStrokes(provider: expectedStrokesProvider)

            derivedShots.append(shot)
        }

        // Third pass: detect penalties
        detectPenalties(in: &derivedShots)

        return derivedShots
    }

    // MARK: - Private Derivation Methods

    private func deriveStartState(for shot: inout DerivedShot, at eventTime: Date, shotNumber: Int) {
        // Get smoothed location
        if let smoothed = locationRecorder.smoothedLocation(at: eventTime) {
            let sample = LocationSample(
                id: UUID().uuidString,
                timestamp: eventTime,
                latitude: smoothed.coordinate.latitude,
                longitude: smoothed.coordinate.longitude,
                horizontalAccuracy: smoothed.avgAccuracy
            )
            shot.startState.location = ProvenanceValue(
                auto: sample,
                confidence: smoothed.confidence,
                source: .gps,
                reasons: smoothed.flags
            )
            shot.confidence.startLocationConfidence = smoothed.confidence
        }

        // Resolve hole
        if let loc = shot.startState.location.value {
            if let resolved = holeResolver.resolveHole(at: loc.coordinate, timestamp: eventTime) {
                shot.holeNumber = ProvenanceValue(
                    auto: resolved.holeNumber,
                    confidence: resolved.confidence,
                    source: .derived,
                    reasons: ["gps_hole_resolution"]
                )
                shot.confidence.holeConfidence = resolved.confidence
            }
        }

        // Calculate distance to pin
        if let loc = shot.startState.location.value,
           let holeNum = shot.holeNumber.value,
           let layout = courseLayout,
           let hole = layout.hole(number: holeNum) {
            let distYards = hole.distanceToPin(from: loc.coordinate)
            shot.startState.distanceToPin = ProvenanceValue(
                auto: distYards,
                confidence: shot.confidence.startLocationConfidence,
                source: .derived,
                reasons: ["calculated_from_gps_and_pin"]
            )
            shot.confidence.distanceConfidence = shot.confidence.startLocationConfidence
        }

        // Get motion stability
        let stability = poseProvider.motionStability(
            from: eventTime.addingTimeInterval(-1),
            to: eventTime.addingTimeInterval(1)
        )

        // Infer lie
        let lieResult = lieAssist.inferLie(
            at: shot.startState.location.value?.coordinate ?? CLLocationCoordinate2D(),
            holeNumber: shot.holeNumber.value,
            shotNumber: shotNumber,
            shotType: shot.shotType.value,
            distanceToPin: shot.startState.distanceToPin.value,
            motionStability: stability
        )
        shot.startState.lie = ProvenanceValue(
            auto: lieResult.lie,
            confidence: lieResult.confidence,
            source: .derived,
            reasons: lieResult.reasons
        )
        shot.confidence.lieConfidence = lieResult.confidence
    }

    private func deriveEndStateFromNextShot(for shot: inout DerivedShot, nextEventTime: Date, currentShotNumber: Int) {
        // Check if next shot is on the same hole
        if let smoothed = locationRecorder.smoothedLocation(at: nextEventTime) {
            let coordinate = smoothed.coordinate

            // Check hole for next position
            let nextHoleResolved = holeResolver.resolveHole(at: coordinate, timestamp: nextEventTime)

            // If same hole, use next shot start as this shot's end
            if nextHoleResolved?.holeNumber == shot.holeNumber.value || shot.holeNumber.value == nil {
                let sample = LocationSample(
                    id: UUID().uuidString,
                    timestamp: nextEventTime,
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    horizontalAccuracy: smoothed.avgAccuracy
                )
                shot.endState.location = ProvenanceValue(
                    auto: sample,
                    confidence: smoothed.confidence,
                    source: .gps,
                    reasons: ["next_shot_start_position"]
                )
                shot.endState.endStateSource = .nextShotStartUsed
                shot.confidence.endLocationConfidence = smoothed.confidence

                // Calculate end distance
                if let holeNum = shot.holeNumber.value,
                   let layout = courseLayout,
                   let hole = layout.hole(number: holeNum) {
                    let distYards = hole.distanceToPin(from: coordinate)

                    // Convert to feet if on/near green
                    let onGreen = hole.isOnGreen(coordinate: coordinate)
                    let distance = onGreen ? distYards * 3 : distYards  // yards to feet if putting

                    shot.endState.distanceToPin = ProvenanceValue(
                        auto: distance,
                        confidence: smoothed.confidence,
                        source: .derived,
                        reasons: onGreen ? ["on_green_distance_in_feet"] : ["distance_in_yards"]
                    )

                    // Infer end lie
                    let lieResult = lieAssist.inferLie(
                        at: coordinate,
                        holeNumber: holeNum,
                        shotNumber: currentShotNumber + 1,
                        shotType: nil,
                        distanceToPin: distance,
                        motionStability: nil
                    )
                    shot.endState.lie = ProvenanceValue(
                        auto: lieResult.lie,
                        confidence: lieResult.confidence,
                        source: .derived,
                        reasons: lieResult.reasons
                    )
                }
            } else {
                // Different hole - this was likely the last shot of the hole (holed out)
                shot.isHoled = true
                shot.holedConfidence = 0.7
                shot.endState.distanceToPin = ProvenanceValue(
                    auto: 0,
                    confidence: 0.7,
                    source: .derived,
                    reasons: ["hole_transition_detected"]
                )
                shot.endState.lie = ProvenanceValue(
                    auto: .green,
                    confidence: 0.7,
                    source: .derived
                )
                shot.endState.endStateSource = .nextShotStartUsed
            }
        } else {
            deriveEndStateFallback(for: &shot, eventTime: nextEventTime)
        }
    }

    private func deriveEndStateFallback(for shot: inout DerivedShot, eventTime: Date) {
        // Use clip end time if available
        let fallbackTime: Date
        if let clipEnd = shot.clipEndSeconds,
           let eventT = shot.event?.eventDate {
            fallbackTime = eventT.addingTimeInterval(clipEnd - (shot.impactSeconds ?? 0))
        } else {
            fallbackTime = eventTime.addingTimeInterval(10)  // 10 seconds after impact
        }

        if let smoothed = locationRecorder.smoothedLocation(at: fallbackTime) {
            let sample = LocationSample(
                id: UUID().uuidString,
                timestamp: fallbackTime,
                latitude: smoothed.coordinate.latitude,
                longitude: smoothed.coordinate.longitude,
                horizontalAccuracy: smoothed.avgAccuracy
            )
            shot.endState.location = ProvenanceValue(
                auto: sample,
                confidence: smoothed.confidence * 0.7,  // Lower confidence for fallback
                source: .gps,
                reasons: ["fallback_timing"]
            )
            shot.endState.endStateSource = .fallbackUsed
            shot.confidence.endLocationConfidence = smoothed.confidence * 0.7
        } else {
            shot.endState.endStateSource = .fallbackUsed
            shot.confidence.endLocationConfidence = 0.2
        }
    }

    private func classifyShot(_ shot: inout DerivedShot) {
        guard let startLie = shot.startState.lie.value else {
            shot.shotType = ProvenanceValue(auto: .unknown, confidence: 0.2, source: .derived)
            shot.confidence.shotTypeConfidence = 0.2
            return
        }

        var shotType: ShotType
        var confidence: Double = 0.7
        var reasons: [String] = []

        switch startLie {
        case .tee:
            shotType = .drive
            reasons.append("from_tee")
            confidence = 0.95
        case .green:
            shotType = .putt
            reasons.append("on_green")
            confidence = 0.95
        case .bunker:
            shotType = .bunkerShot
            reasons.append("from_bunker")
            confidence = 0.9
        case .fringe:
            if let dist = shot.startState.distanceToPin.value, dist < 10 {
                shotType = .chip
                reasons.append("short_fringe_shot")
            } else {
                shotType = .pitch
                reasons.append("fringe_pitch")
            }
        case .fairway, .rough, .deepRough:
            if let dist = shot.startState.distanceToPin.value {
                if dist <= 20 {
                    shotType = .chip
                    reasons.append("short_distance")
                } else if dist <= 50 {
                    shotType = .pitch
                    reasons.append("medium_distance")
                } else {
                    shotType = .approach
                    reasons.append("full_swing_distance")
                }
            } else {
                shotType = .approach
                reasons.append("default_approach")
                confidence = 0.5
            }
        case .recovery:
            shotType = .approach  // Could be punch, chip, etc.
            reasons.append("recovery_lie")
            confidence = 0.5
        case .unknown:
            shotType = .unknown
            confidence = 0.2
        }

        shot.shotType = ProvenanceValue(
            auto: shotType,
            confidence: confidence,
            source: .derived,
            reasons: reasons
        )
        shot.confidence.shotTypeConfidence = confidence
    }

    private func detectPenalties(in shots: inout [DerivedShot]) {
        for i in 1..<shots.count {
            let prevShot = shots[i - 1]
            let currentShot = shots[i]

            // Check for distance increase (ball went backwards or sideways significantly)
            if let prevEndDist = prevShot.endState.distanceToPin.value,
               let currStartDist = currentShot.startState.distanceToPin.value {

                // If current start is further than prev end by significant margin
                if currStartDist > prevEndDist + 30 {  // 30 yards threshold
                    shots[i].isPenaltyLikely = true
                    shots[i].auditEvents.append(AuditEvent(
                        field: "penalty",
                        oldValue: nil,
                        newValue: "likely",
                        source: "distance_regression_detection"
                    ))
                }
            }

            // Check for hole discontinuity (jumped holes unexpectedly)
            if prevShot.holeNumber.value != currentShot.holeNumber.value,
               !prevShot.isHoled {
                shots[i - 1].isPenaltyLikely = true
                shots[i - 1].auditEvents.append(AuditEvent(
                    field: "penalty",
                    oldValue: nil,
                    newValue: "likely",
                    source: "hole_discontinuity"
                ))
            }
        }
    }
}
