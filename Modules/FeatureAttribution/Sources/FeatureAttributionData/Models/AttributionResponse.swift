import Foundation

public enum Channel: String, Codable {
    case conversion
    case heartbeat
}

public enum EventType: String, Codable {
    case subscribed
    case updated
}

public struct AttributionResponse: Equatable {
    public struct Updated: Equatable, Codable {
        public let seqnum: Int
        public let event: EventType
        public let channel: Channel
        public var conversionValue: Int
    }

    public struct Subscribed: Equatable, Codable {
        public let seqnum: Int
        public let event: EventType
        public let channel: Channel
    }
}
