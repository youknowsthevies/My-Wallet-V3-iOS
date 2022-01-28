// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public final class AddressLabel: Equatable {
    public internal(set) var index: Int
    public internal(set) var label: String

    public init(
        index: Int,
        label: String
    ) {
        self.index = index
        self.label = label
    }
}

extension AddressLabel {
    public static func == (lhs: AddressLabel, rhs: AddressLabel) -> Bool {
        lhs.index == rhs.index
            && lhs.label == rhs.label
    }
}
