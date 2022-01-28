// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public final class Address: Equatable {
    public internal(set) var addr: String
    public internal(set) var priv: String?
    public internal(set) var tag: Int
    public internal(set) var label: String
    public internal(set) var createdTime: Int
    public internal(set) var createdDeviceName: String
    public internal(set) var createdDeviceVersion: String

    var isArchived: Bool {
        tag == 2
    }

    var isActive: Bool {
        !isArchived
    }

    var isWatchOnly: Bool {
        priv == nil
    }

    public init(
        addr: String,
        priv: String?,
        tag: Int,
        label: String,
        createdTime: Int,
        createdDeviceName: String,
        createdDeviceVersion: String
    ) {
        self.addr = addr
        self.priv = priv
        self.tag = tag
        self.label = label
        self.createdTime = createdTime
        self.createdDeviceName = createdDeviceName
        self.createdDeviceVersion = createdDeviceVersion
    }
}

extension Address {
    public static func == (lhs: Address, rhs: Address) -> Bool {
        lhs.addr == rhs.addr
            && lhs.priv == rhs.priv
            && lhs.tag == rhs.tag
            && lhs.label == rhs.label
            && lhs.createdTime == rhs.createdTime
            && lhs.createdDeviceName == rhs.createdDeviceName
            && lhs.createdDeviceVersion == rhs.createdDeviceVersion
    }
}
