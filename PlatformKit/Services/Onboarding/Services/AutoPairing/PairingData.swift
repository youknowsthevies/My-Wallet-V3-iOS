//
//  PairingData.swift
//  PlatformKit
//
//  Created by Daniel Huri on 20/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct PairingData {
    
    /// The wallet GUID
    let guid: String
    
    /// The wallet encrypted shared key
    let encryptedSharedKey: String
    
    public init(guid: String, encryptedSharedKey: String) {
        self.guid = guid
        self.encryptedSharedKey = encryptedSharedKey
    }
}
