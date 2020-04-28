//
//  LocalizationConstants+AddCard.swift
//  Localization
//
//  Created by Daniel Huri on 17/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

extension LocalizationConstants {
    public struct CardDetailsScreen {
        public static let title = NSLocalizedString(
            "Add a Card",
            comment: "Add Card Screen: screen title"
        )
        public static let notice = NSLocalizedString(
            "Privacy protected with 256-Bit SSL encryption.",
            comment: "Add Card Screen: privacy notice label"
        )
        public static let button = NSLocalizedString(
            "Add Now",
            comment: "Add Card Screen: add card button label"
        )
    }
    public struct BillingAddressScreen {
        public static let title = NSLocalizedString(
            "Billing Address",
            comment: "Billing Address Screen: screen title"
        )
        public static let button = NSLocalizedString(
            "Next",
            comment: "Billing Address Screen: add card button label"
        )
        public static let linkingYourCard = NSLocalizedString(
            "Secrurely Linking Your Card",
            comment: "Billing Address Screen: loader"
        )
    }
    public struct AuthorizeCardScreen {
        public static let title = NSLocalizedString(
            "Authorize Card",
            comment: "Card Authorization Screen: screen title"
        )
    }
    public struct CountrySelectionScreen {
        public static let title = NSLocalizedString(
            "Select Country",
            comment: "Country Selection Screen: title"
        )
        public static let searchBarPlaceholder = NSLocalizedString(
            "Search Country",
            comment: "Country Selection Screen: search bar placeholder"
        )
    }
    public enum PendingCardStatusScreen {
        public enum LoadingScreen {
            public static let title = NSLocalizedString(
                "Secrurely Linking Your Card",
                comment: "Pending active card screen: title"
            )
            public static let subtitle = NSLocalizedString(
                "This could take up to 1 minute.",
                comment: "Pending active card screen: subtitle"
            )
        }
    }
    
}
