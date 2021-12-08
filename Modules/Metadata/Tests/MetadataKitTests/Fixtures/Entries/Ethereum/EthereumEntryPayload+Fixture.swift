// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
@testable import MetadataKit
import TestKit

extension EthereumEntryPayload {

    static var fixture: EthereumEntryPayload {
        Fixtures.load(name: "ethereum_entry", in: .module)!
    }
}
