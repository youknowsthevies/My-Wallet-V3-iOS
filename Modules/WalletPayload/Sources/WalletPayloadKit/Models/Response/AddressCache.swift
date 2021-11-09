// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct AddressCache: Equatable, Codable {
    let receiveAccount: String
    let changeAccount: String
}
