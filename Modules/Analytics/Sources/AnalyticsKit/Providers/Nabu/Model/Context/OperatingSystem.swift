// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct OperatingSystem: Encodable {
    let name: String
    let version: String
}

#if canImport(UIKit)
import UIKit

extension OperatingSystem {

    init(device: UIDevice = UIDevice.current) {
        name = device.systemName
        version = device.systemVersion
    }
}

#endif

#if canImport(AppKit)
import AppKit

extension OperatingSystem {

    init() {
        name = "macos"
        version = ProcessInfo.processInfo.operatingSystemVersionString
    }
}

#endif
