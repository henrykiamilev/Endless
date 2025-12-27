import Foundation
import CoreLocation

// MARK: - Strokes Gained Core Engine
// A dependency-free core module for computing strokes gained analytics
// Uses only Foundation + CoreLocation

// MARK: - Provenance & Confidence

/// Represents a value with its source provenance and confidence level
struct ProvenanceValue<T: Codable>: Codable where T: Equatable {
    var autoValue: T?
    var userOverride: T?
    var confidence: Double  // 0.0 - 1.0
    var source: ValueSource
    var reasonCodes: [String]

    var value: T? {
        userOverride ?? autoValue
    }

    var isUserOverridden: Bool {
        userOverride != nil
    }

    enum ValueSource: String, Codable {
        case gps
        case video
        case derived
        case userInput
        case fallback
        case unknown
    }

    init(auto: T? = nil, override: T? = nil, confidence: Double = 0.0, source: ValueSource = .unknown, reasons: [String] = []) {
        self.autoValue = auto
        self.userOverride = override
        self.confidence = confidence
        self.source = source
        self.reasonCodes = reasons
    }
}

/// Audit event for tracking changes
struct AuditEvent: Codable, Identifiable {
    let id: String
    let timestamp: Date
    let field: String
    let oldValue: String?
    let newValue: String
    let source: String

    init(id: String = UUID().uuidString, field: String, oldValue: String?, newValue: String, source: String) {
        self.id = id
        self.timestamp = Date()
        self.field = field
        self.oldValue = oldValue
        self.newValue = newValue
        self.source = source
    }
}

// MARK: - Shot Classification

/// The lie/surface type of the ball
enum Lie: String, Codable, CaseIterable {
    case tee
    case fairway
    case rough
    case deepRough
    case bunker
    case green
    case fringe
    case recovery  // Trees, hazard, etc.
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

/// Type of shot played
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

/// Strokes Gained category for analysis
enum SGCategory: String, Codable, CaseIterable {
    case offTheTee = "OTT"
    case approach = "APP"
    case shortGame = "ARG"  // Around the Green
    case putting = "PUTT"

    var displayName: String {
        switch self {
        case .offTheTee: return "Off the Tee"
        case .approach: return "Approach"
        case .shortGame: return "Short Game"
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
}

// MARK: - Distance Bands

/// Distance band for approach/full shots (in yards)
enum DistanceBand: String, Codable, CaseIterable {
    case band0_30 = "0-30"
    case band30_75 = "30-75"
    case band75_125 = "75-125"
    case band125_175 = "125-175"
    case band175_225 = "175-225"
    case band225Plus = "225+"

    var range: ClosedRange<Double> {
        switch self {
        case .band0_30: return 0...30
        case .band30_75: return 30...75
        case .band75_125: return 75...125
        case .band125_175: return 125...175
        case .band175_225: return 175...225
        case .band225Plus: return 225...1000
        }
    }

    static func band(for distance: Double) -> DistanceBand {
        for band in allCases {
            if band.range.contains(distance) {
                return band
            }
        }
        return .band225Plus
    }
}

/// Putting distance band (in feet)
enum PuttingBand: String, Codable, CaseIterable {
    case band0_3 = "0-3 ft"
    case band3_4 = "3-4 ft"
    case band4_8 = "4-8 ft"
    case band8_10 = "8-10 ft"
    case band10_15 = "10-15 ft"
    case band15_20 = "15-20 ft"
    case band20_25 = "20-25 ft"
    case band25Plus = "25+ ft"

    var range: ClosedRange<Double> {
        switch self {
        case .band0_3: return 0...3
        case .band3_4: return 3...4
        case .band4_8: return 4...8
        case .band8_10: return 8...10
        case .band10_15: return 10...15
        case .band15_20: return 15...20
        case .band20_25: return 20...25
        case .band25Plus: return 25...200
        }
    }

    static func band(for distanceFeet: Double) -> PuttingBand {
        for band in allCases {
            if band.range.contains(distanceFeet) {
                return band
            }
        }
        return .band25Plus
    }
}

// MARK: - Shot Event (from Video)

/// A shot event captured from video analysis
struct ShotEvent: Codable, Identifiable {
    let id: String
    var roundId: String?

    // Video timing
    var clipStartSeconds: Double?
    var impactSeconds: Double?
    var clipEndSeconds: Double?
    var secondsFromVideoStart: Double?
    var recordedAt: Date?

    // Derived absolute time
    var eventDate: Date?

    // Device pose (optional interface for x/y/z)
    var devicePosition: DevicePosition?
    var motionStability: Double?  // 0-1, variance in translation/rotation

    init(id: String = UUID().uuidString) {
        self.id = id
    }
}

/// Device position/orientation at impact
struct DevicePosition: Codable {
    var x: Double
    var y: Double
    var z: Double
    var pitch: Double?
    var yaw: Double?
    var roll: Double?
}

// MARK: - Video Session Timebase

/// Converts video-relative times to absolute dates
struct VideoSessionTimebase {
    let sessionStartDate: Date
    let videoStartOffset: Double  // Seconds from session start to video start

    /// Convert seconds from video start to absolute Date
    func absoluteDate(secondsFromVideoStart: Double) -> Date {
        sessionStartDate.addingTimeInterval(videoStartOffset + secondsFromVideoStart)
    }

    /// Standardize a ShotEvent's eventDate using available timing info
    func standardizeEventDate(for event: inout ShotEvent) {
        // Prefer recordedAt if available
        if let recordedAt = event.recordedAt {
            event.eventDate = recordedAt
            return
        }

        // Otherwise derive from secondsFromVideoStart
        if let seconds = event.secondsFromVideoStart {
            event.eventDate = absoluteDate(secondsFromVideoStart: seconds)
            return
        }

        // Fallback: use impactSeconds relative to session
        if let impact = event.impactSeconds {
            event.eventDate = absoluteDate(secondsFromVideoStart: impact)
        }
    }
}

// MARK: - GPS Location Sample

/// A GPS sample with accuracy metadata
struct LocationSample: Codable, Identifiable, Equatable {
    let id: String
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let altitude: Double?
    let horizontalAccuracy: Double
    let verticalAccuracy: Double?
    let speed: Double?
    let course: Double?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var clLocation: CLLocation {
        CLLocation(
            coordinate: coordinate,
            altitude: altitude ?? 0,
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: verticalAccuracy ?? -1,
            timestamp: timestamp
        )
    }

    init(from location: CLLocation) {
        self.id = UUID().uuidString
        self.timestamp = location.timestamp
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.horizontalAccuracy = location.horizontalAccuracy
        self.verticalAccuracy = location.verticalAccuracy
        self.speed = location.speed >= 0 ? location.speed : nil
        self.course = location.course >= 0 ? location.course : nil
    }

    init(id: String = UUID().uuidString, timestamp: Date, latitude: Double, longitude: Double,
         horizontalAccuracy: Double, altitude: Double? = nil, verticalAccuracy: Double? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.speed = nil
        self.course = nil
    }
}

// MARK: - Smoothed Location Result

/// Result of GPS smoothing with confidence
struct SmoothedLocation {
    let coordinate: CLLocationCoordinate2D
    let altitude: Double?
    let confidence: Double  // 0-1
    let sampleCount: Int
    let avgAccuracy: Double
    let flags: [String]

    var isHighConfidence: Bool {
        confidence >= 0.7 && avgAccuracy <= 10.0
    }
}

// MARK: - End State Source

/// How the end state of a shot was determined
enum EndStateSource: String, Codable {
    case nextShotStartUsed
    case clipEndUsed
    case fallbackUsed
    case userProvided
    case unknown
}

// MARK: - Shot State

/// The state (position/lie) at start or end of a shot
struct ShotState: Codable {
    var location: ProvenanceValue<LocationSample>
    var lie: ProvenanceValue<Lie>
    var distanceToPin: ProvenanceValue<Double>  // In yards for full shots, feet for putts
    var expectedStrokes: Double?
    var endStateSource: EndStateSource?

    init() {
        self.location = ProvenanceValue()
        self.lie = ProvenanceValue()
        self.distanceToPin = ProvenanceValue()
    }
}

// MARK: - Derived Shot

/// A fully derived shot with SG calculation
struct DerivedShot: Codable, Identifiable {
    let id: String
    var roundId: String?
    var holeNumber: ProvenanceValue<Int>
    var shotNumber: Int

    // Event reference
    var eventId: String?
    var event: ShotEvent?

    // States
    var startState: ShotState
    var endState: ShotState

    // Classification
    var shotType: ProvenanceValue<ShotType>
    var category: SGCategory?

    // Strokes Gained
    var strokesGained: Double?
    var penaltyStrokes: Int
    var isPenaltyLikely: Bool

    // Putting specific
    var isHoled: Bool
    var holedConfidence: Double  // 0-1

    // Confidence breakdown
    var confidence: ShotConfidence

    // Video deep link
    var clipStartSeconds: Double?
    var impactSeconds: Double?
    var clipEndSeconds: Double?

    // Audit trail
    var auditEvents: [AuditEvent]

    init(id: String = UUID().uuidString, shotNumber: Int = 1) {
        self.id = id
        self.shotNumber = shotNumber
        self.holeNumber = ProvenanceValue()
        self.startState = ShotState()
        self.endState = ShotState()
        self.shotType = ProvenanceValue()
        self.penaltyStrokes = 0
        self.isPenaltyLikely = false
        self.isHoled = false
        self.holedConfidence = 0
        self.confidence = ShotConfidence()
        self.auditEvents = []
    }
}

/// Confidence breakdown for a shot
struct ShotConfidence: Codable {
    var holeConfidence: Double = 0
    var startLocationConfidence: Double = 0
    var endLocationConfidence: Double = 0
    var distanceConfidence: Double = 0
    var lieConfidence: Double = 0
    var shotTypeConfidence: Double = 0

    var overall: Double {
        let weights = [0.1, 0.2, 0.2, 0.2, 0.15, 0.15]
        let values = [holeConfidence, startLocationConfidence, endLocationConfidence,
                      distanceConfidence, lieConfidence, shotTypeConfidence]
        return zip(weights, values).reduce(0) { $0 + $1.0 * $1.1 }
    }

    var isHighConfidence: Bool {
        overall >= 0.7
    }

    var needsReview: Bool {
        overall < 0.5
    }
}

// MARK: - Hole Data

/// Pin/hole location data
struct HoleLocation: Codable {
    let holeNumber: Int
    let par: Int
    let teeLocation: CLLocationCoordinate2D
    let greenCenter: CLLocationCoordinate2D
    let pinLocation: CLLocationCoordinate2D?
    let yardage: Double

    // Green boundaries (simplified as radius for now)
    let greenRadius: Double  // yards

    func distanceToPin(from coordinate: CLLocationCoordinate2D) -> Double {
        let pin = pinLocation ?? greenCenter
        let from = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let to = CLLocation(latitude: pin.latitude, longitude: pin.longitude)
        return from.distance(from: to) * 1.09361  // meters to yards
    }

    func isOnGreen(coordinate: CLLocationCoordinate2D) -> Bool {
        let from = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let center = CLLocation(latitude: greenCenter.latitude, longitude: greenCenter.longitude)
        let distanceYards = from.distance(from: center) * 1.09361
        return distanceYards <= greenRadius
    }

    // MARK: - Codable Implementation

    enum CodingKeys: String, CodingKey {
        case holeNumber, par, yardage, greenRadius
        case teeLatitude, teeLongitude
        case greenCenterLatitude, greenCenterLongitude
        case pinLatitude, pinLongitude
    }

    init(holeNumber: Int, par: Int, teeLocation: CLLocationCoordinate2D, greenCenter: CLLocationCoordinate2D, pinLocation: CLLocationCoordinate2D?, yardage: Double, greenRadius: Double) {
        self.holeNumber = holeNumber
        self.par = par
        self.teeLocation = teeLocation
        self.greenCenter = greenCenter
        self.pinLocation = pinLocation
        self.yardage = yardage
        self.greenRadius = greenRadius
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        holeNumber = try container.decode(Int.self, forKey: .holeNumber)
        par = try container.decode(Int.self, forKey: .par)
        yardage = try container.decode(Double.self, forKey: .yardage)
        greenRadius = try container.decode(Double.self, forKey: .greenRadius)

        let teeLat = try container.decode(Double.self, forKey: .teeLatitude)
        let teeLon = try container.decode(Double.self, forKey: .teeLongitude)
        teeLocation = CLLocationCoordinate2D(latitude: teeLat, longitude: teeLon)

        let greenLat = try container.decode(Double.self, forKey: .greenCenterLatitude)
        let greenLon = try container.decode(Double.self, forKey: .greenCenterLongitude)
        greenCenter = CLLocationCoordinate2D(latitude: greenLat, longitude: greenLon)

        if let pinLat = try container.decodeIfPresent(Double.self, forKey: .pinLatitude),
           let pinLon = try container.decodeIfPresent(Double.self, forKey: .pinLongitude) {
            pinLocation = CLLocationCoordinate2D(latitude: pinLat, longitude: pinLon)
        } else {
            pinLocation = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(holeNumber, forKey: .holeNumber)
        try container.encode(par, forKey: .par)
        try container.encode(yardage, forKey: .yardage)
        try container.encode(greenRadius, forKey: .greenRadius)

        try container.encode(teeLocation.latitude, forKey: .teeLatitude)
        try container.encode(teeLocation.longitude, forKey: .teeLongitude)

        try container.encode(greenCenter.latitude, forKey: .greenCenterLatitude)
        try container.encode(greenCenter.longitude, forKey: .greenCenterLongitude)

        if let pin = pinLocation {
            try container.encode(pin.latitude, forKey: .pinLatitude)
            try container.encode(pin.longitude, forKey: .pinLongitude)
        }
    }
}

/// Course layout data
struct CourseLayout: Codable {
    let courseId: String
    let courseName: String
    let holes: [HoleLocation]

    func hole(number: Int) -> HoleLocation? {
        holes.first { $0.holeNumber == number }
    }
}

// MARK: - Pose Provider Protocol

/// Protocol for providing device pose data from video
protocol PoseProvider {
    /// Get device position near impact time
    func position(at timestamp: Date) -> DevicePosition?

    /// Get motion stability metric (0-1, lower = more stable)
    func motionStability(from startTime: Date, to endTime: Date) -> Double?
}

/// Default implementation when no pose data available
struct NullPoseProvider: PoseProvider {
    func position(at timestamp: Date) -> DevicePosition? { nil }
    func motionStability(from startTime: Date, to endTime: Date) -> Double? { nil }
}
