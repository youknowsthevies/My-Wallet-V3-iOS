// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCryptoKit

public struct HDPublicKey: HexRepresentable {
    
    public let data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
}
