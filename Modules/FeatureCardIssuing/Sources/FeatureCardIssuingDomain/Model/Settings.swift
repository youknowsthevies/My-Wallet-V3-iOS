// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct CardSettings: Codable {

    public let locked: Bool

    public let swipePaymentsEnabled: Bool

    public let contactlessPaymentsEnabled: Bool

    public let preAuthEnabled: Bool

    public let address: Card.Address

    public init(
        locked: Bool,
        swipePaymentsEnabled: Bool,
        contactlessPaymentsEnabled: Bool,
        preAuthEnabled: Bool,
        address: Card.Address
    ) {
        self.locked = locked
        self.swipePaymentsEnabled = swipePaymentsEnabled
        self.contactlessPaymentsEnabled = contactlessPaymentsEnabled
        self.preAuthEnabled = preAuthEnabled
        self.address = address
    }
}
