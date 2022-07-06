// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum WebsocketEvent: Decodable, Equatable {
    case heartbeatUpdated(HeartbeatResponse)
    case conversionValueUpdated(AttributionResponse.Updated)
    case conversionValueSubscribed(AttributionResponse.Subscribed)

    private enum CodingKeys: String, CodingKey {
        case channel
        case event
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let channel = try container.decode(Channel.self, forKey: .channel)
        let event = try container.decode(EventType.self, forKey: .event)
        let singleValueContainer = try decoder.singleValueContainer()

        switch channel {

        case .heartbeat:
            switch event {
            case .subscribed, .updated:
                let response = try singleValueContainer.decode(HeartbeatResponse.self)
                self = .heartbeatUpdated(response)
            }

        case .conversion:
            switch event {
            case .updated:
                let response = try singleValueContainer.decode(AttributionResponse.Updated.self)
                self = .conversionValueUpdated(response)

            case .subscribed:
                let response = try singleValueContainer.decode(AttributionResponse.Subscribed.self)
                self = .conversionValueSubscribed(response)
            }
        }
    }
}
