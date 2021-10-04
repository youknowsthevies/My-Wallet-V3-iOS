// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension AccountPickerRow {

    public struct SingleAccount: Equatable, Identifiable {

        // MARK: - Public properties

        public var fiatBalance: String
        public var cryptoBalance: String

        public let id: AnyHashable

        // MARK: - Internal properties

        var title: String
        var description: String

        // MARK: - Init

        public init(
            id: AnyHashable,
            title: String,
            description: String,
            fiatBalance: String,
            cryptoBalance: String
        ) {
            self.id = id
            self.title = title
            self.description = description
            self.fiatBalance = fiatBalance
            self.cryptoBalance = cryptoBalance
        }
    }
}
