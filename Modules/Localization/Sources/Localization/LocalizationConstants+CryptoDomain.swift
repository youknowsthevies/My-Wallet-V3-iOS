// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    public enum FeatureCryptoDomain {}
}

extension LocalizationConstants.FeatureCryptoDomain {

    // MARK: - Search Domain Screen

    public enum SearchDomain {
        public static let title = NSLocalizedString(
            "Search Domains",
            comment: "Search Domains list view navigation title"
        )
        public enum Description {
            public static let title = NSLocalizedString(
                "What's a free domain?",
                comment: "Search Domains list view description title"
            )
            public static let body = NSLocalizedString(
                "Free domains must be a minimum of 7 characters long and not a special domain like nike.blockchain.",
                comment: "Search Domains list view description body"
            )
        }
        public enum ListView {
            public static let freeDomain = NSLocalizedString(
                "Free domain",
                comment: "Search Domains list view free domain status"
            )
            public static let premiumDomain = NSLocalizedString(
                "Premium domain",
                comment: "Search Domains list view premium domain status"
            )
            public static let free = NSLocalizedString(
                "Free",
                comment: "Search Domains list view availability status (free)"
            )
            public static let unavailable = NSLocalizedString(
                "Unavailable",
                comment: "Search Domains list view availability status (unavailable)"
            )
        }
    }
}
