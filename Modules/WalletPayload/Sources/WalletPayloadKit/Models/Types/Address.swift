// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct Address: Equatable {
    var addr: String
    var priv: String?
    var tag: Int
    var label: String
    var createdTime: Int
    var createdDeviceName: String
    var createdDeviceVersion: String

    var isArchived: Bool {
        tag == 2
    }

    var isActive: Bool {
        !isArchived
    }

    var isWatchOnly: Bool {
        priv == nil
    }

    init(from model: WalletResponseModels.Address) {
        addr = model.addr
        priv = model.priv
        tag = model.tag
        label = model.label
        createdTime = model.createdTime
        createdDeviceName = model.createdDeviceName
        createdDeviceVersion = model.createdDeviceVersion
    }
}
