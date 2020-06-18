//
//  PasscodePayload.swift
//  Blockchain
//
//  Created by Maurice A. on 4/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Represents a passcode payload used for authenticating the user.
public struct PasscodePayload {
    public let guid: String
    public let password: String
    public let sharedKey: String

    public init(guid: String, password: String, sharedKey: String) {
        self.guid = guid
        self.password = password
        self.sharedKey = sharedKey
    }
}
