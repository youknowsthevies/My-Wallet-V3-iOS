// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct HeartbeatResponse: Equatable, Decodable {
    public let seqnum: Int
    public let event: EventType
    public let channel: Channel
}
