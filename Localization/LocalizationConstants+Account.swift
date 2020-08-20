//
//  LocalizationConstants+Account.swift
//  Localization
//
//  Created by Paulo on 11/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension LocalizationConstants {
    public enum Account {
        public static let myWallet = NSLocalizedString(
            "My %@ Wallet",
            comment: "Must contain %@. Used for naming wallets e.g. My Ethereum Wallet"
        )

        public static let myInterestAccount = NSLocalizedString(
            "My %@ Interest Account",
            comment: "Must contain %@. Used for naming interest account e.g. My Ethereum Interest Account"
        )

        public static let myTradingAccount = NSLocalizedString(
            "My %@ Trading Account",
            comment: "Must contain %@. Used for naming trading accounts e.g. My Ethereum Trading Account"
        )
    }

    public enum AccountGroup {
        public static let allWallets = NSLocalizedString(
            "All Wallets",
            comment: "All Wallets"
        )

        public static let myAccounts = NSLocalizedString(
            "My %@ Accounts",
            comment: "Must contain %@. Used for naming accounts e.g. My Ethereum Accounts"
        )

        public static let myInterestAccounts = NSLocalizedString(
            "My %@ Interest Accounts",
            comment: "Must contain %@. Used for naming interest account e.g. My Ethereum Interest Accounts"
        )

        public static let myTradingAccounts = NSLocalizedString(
            "My %@ Trading Accounts",
            comment: "Must contain %@. Used for naming trading accounts e.g. My Ethereum Trading Accounts"
        )

        public static let myCustodialAccounts = NSLocalizedString(
            "My %@ Custodial Accounts",
            comment: "Must contain %@. Used for naming trading accounts e.g. My Ethereum Custodial Accounts"
        )
    }
}
