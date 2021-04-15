//
//  DeviceInfo.swift
//  ToolKit
//
//  Created by Daniel on 26/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public protocol DeviceInfo {
    var systemVersion: String { get }
    var model: String { get }
    var uuidString: String { get }
}
