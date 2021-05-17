// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public final class BankAccountReceiveAddress: ReceiveAddress {
    public let address: String
    public let label: String

    public init(address: String, label: String) {
        self.address = address
        self.label = label
    }
}
