// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct AddressLabel: Equatable {
    public let index: Int
    public let label: String

    public init(
        index: Int,
        label: String
    ) {
        self.index = index
        self.label = label
    }
}
