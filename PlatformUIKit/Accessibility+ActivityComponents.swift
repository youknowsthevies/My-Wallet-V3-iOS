//
//  Accessibility+ActivityComponents.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 6/1/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

extension Accessibility.Identifier {
    public struct Activity {
        private static let prefix = "Activity."
        public enum WalletPickerView {
            private static let prefix = "\(Activity.prefix)WalletPickerView"
            public static let name = prefix
            public enum WalletCellItem {
                private static let prefix = "\(WalletPickerView.prefix).WalletPickerCellItem"
                public static let cryptoValue = "\(prefix).cryptoValue"
                public static let fiatValue = "\(prefix).fiatValue"
                public static let titleValue = "\(prefix).titleValue"
                public static let descriptionValue = "\(prefix).descriptionValue"
            }
        }
        public enum WalletBalance {
            private static let prefix = "\(Activity.prefix)WalletBalance."
            public static let cell = "\(prefix)cell"
            public static let view = "\(prefix)view"
            public static let title = "\(prefix)title"
            public static let description = "\(prefix)description"
            public static let badgeView = "\(prefix)badgeView"
            public static let fiatBalance = "\(prefix)fiatBalanceLabel"
            public static let currencyCode = "\(prefix)currencyCodeLabel"
        }
        public enum ActivityCell {
            private static let prefix = "\(Activity.prefix)ActivityCell."
            public static let view = "\(prefix)view"
            public static let badge = "\(prefix)badge"
            public static let titleLabel = "\(prefix)titleLabel"
            public static let descriptionLabel = "\(prefix)descriptionLabel"
            public static let cryptoValue = "\(prefix)cryptoValue"
            public static let fiatValue = "\(prefix)fiatValue"
        }
        public enum EmptyState {
            private static let prefix = "\(Activity.prefix)EmptyState."
            public static let titleLabel = "\(prefix)titleLabel"
            public static let descriptionLabel = "\(prefix)descriptionLabel"
            public static let imageView = "\(prefix)imageView"
        }
    }
}

