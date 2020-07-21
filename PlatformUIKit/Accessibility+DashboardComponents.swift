//
//  Accessibility+DashboardComponents.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 06/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

extension Accessibility.Identifier {
    public struct Dashboard {
        private static let prefix = "Dashboard."
        public struct FiatCustodialCell {
            public static let prefix = "\(Dashboard.prefix)FiatCustodialCell."
            public static let currencyName = "\(prefix)currencyName"
            public static let currencyCode = "\(prefix)currencyCode"
            public static let currencyBadgeView = "\(prefix)currencyBadgeView"
            public static let baseFiatBalance = "\(prefix)baseFiatBalance"
            public static let quoteFiatBalance = "\(prefix)quoteFiatBalance"
        }
        public struct CurrentBalanceCell {
            public static let prefix = "\(Dashboard.prefix)CurrentBalance."
            public static let view = "\(prefix)view"
            public static let title = "\(prefix)title"
            public static let description = "\(prefix)description"
        }
        public struct Notice {
            private static let prefix = "\(Dashboard.prefix)Notice."
            public static let label = "\(prefix)label"
            public static let imageView = "\(prefix)imageView"
        }
        public struct TotalBalanceCell {
            private static let prefix = "\(Dashboard.prefix)TotalBalanceCell."
            public static let titleLabel = "\(prefix)titleLabel"
            public static let valueLabelSuffix = "\(prefix)total"
            public static let pieChartView = "\(prefix)pieChartView"
        }
        public struct AssetCell {
            private static let prefix = "\(Dashboard.prefix)AssetCell."
            public static let titleLabelFormat = "\(prefix)titleLabel."
            public static let assetImageView = "\(prefix)assetImageView."
            public static let fiatPriceLabelFormat = "\(prefix)fiatPriceLabelFormat."
            public static let changeLabelFormat = "\(prefix)changeLabelFormat."
            public static let fiatBalanceLabelFormat = "\(prefix)fiatBalanceLabel."
            public static let cryptoBalanceLabelFormat = "\(prefix)cryptoBalanceLabel."
        }
        struct Announcement {
            private static let prefix = "\(Dashboard.prefix)Announcement."
            
            static let titleLabel = "\(prefix)titleLabel"
            static let descriptionLabel = "\(prefix)descriptionLabel"
            static let imageView = "\(prefix)thumbImageView"
            static let dismissButton = "\(prefix)dismissButton"
            static let backgroundButton = "\(prefix)backgroundButton"
        }
    }
    public struct DashboardDetails {
        private static let prefix = "DashboardDetails."
        public struct CurrentBalanceCell {
            public static let prefix = "\(DashboardDetails.prefix)CurrentBalance."
            public static let titleValue = "\(prefix)titleValue"
            public static let descriptionValue = "\(prefix)descriptionValue"
            public static let cryptoValue = "\(prefix)cryptoValue"
            public static let fiatValue = "\(prefix)fiatValue"
        }
        public struct WalletActionSheet {
            public static let prefix = "\(DashboardDetails.prefix)WalletActionSheet."
            public enum NonCustodial {
                public static let prefix = "\(WalletActionSheet.prefix)NonCustodial"
                public static let cryptoValue = "\(prefix)cryptoValue"
                public static let fiatValue = "\(prefix)fiatValue"
            }
            public enum Withdrawal {
                private static let prefix = "Withdrawal."
                public static let cryptoValue = "\(prefix)AssetBalanceView.cryptoBalanceValue"
                public static let fiatValue = "\(prefix)AssetBalanceView.fiatBalanceValue"
            }
            public enum CustodialAction {
                private static let prefix = "CustodialAction."
                public static let cryptoValue = "\(prefix)AssetBalanceView.cryptoBalanceValue"
                public static let fiatValue = "\(prefix)AssetBalanceView.fiatBalanceValue"
            }
        }
    }
}
