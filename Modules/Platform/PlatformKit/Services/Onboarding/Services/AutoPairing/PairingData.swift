// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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
