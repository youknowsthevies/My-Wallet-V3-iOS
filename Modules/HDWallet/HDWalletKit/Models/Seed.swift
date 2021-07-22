// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCryptoKit

struct Seed: HexRepresentable {

    let data: Data

    init(data: Data) {
        self.data = data
    }
}
