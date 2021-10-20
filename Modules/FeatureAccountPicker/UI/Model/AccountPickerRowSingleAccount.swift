// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableNavigation
import SwiftUI

extension AccountPickerRow {

    public struct SingleAccount: Equatable, Identifiable {

        // MARK: - Public properties

        public var fiatBalance: LoadingState<String>
        public var cryptoBalance: LoadingState<String>

        public let id: AnyHashable

        // MARK: - Internal properties

        var title: String
        var description: String

        // MARK: - Init

        public init(
            id: AnyHashable,
            title: String,
            description: String,
            fiatBalance: LoadingState<String>,
            cryptoBalance: LoadingState<String>
        ) {
            self.id = id
            self.title = title
            self.description = description
            self.fiatBalance = fiatBalance
            self.cryptoBalance = cryptoBalance
        }
    }
}
