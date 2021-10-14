// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct Address: Equatable, Codable {
    let addr: String
    let priv: String?
    let tag: Int
    let label: String
    let createdTime: Int
    let createdDeviceName: String
    let createdDeviceVersion: String

    enum CodingKeys: String, CodingKey {
        case addr
        case priv
        case tag
        case label
        case createdTime = "created_time"
        case createdDeviceName = "created_device_name"
        case createdDeviceVersion = "created_device_version"
    }
}
