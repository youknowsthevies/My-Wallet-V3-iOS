// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCryptoKit
import LibWally

public struct Seed: HexRepresentable {

    public let data: Data

    public init(data: Data) {
        self.data = data
    }

}
