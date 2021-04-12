//
//  SiftServiceAPI.swift
//  PlatformKit
//
//  Created by Dimitrios Chatzieleftheriou on 30/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol SiftServiceAPI {
    func enable()
    func set(userId: String)
    func removeUserId()
}
