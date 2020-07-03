//
//  MockDeviceInfo.swift
//  PlatformKitTests
//
//  Created by Daniel on 30/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import ToolKit

struct MockDeviceInfo: DeviceInfo {
    let systemVersion: String
    let model: String
    let uuidString: String
}
