//
//  CryptoCurrency+Account.swift
//  PlatformKit
//
//  Created by Paulo on 20/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization

extension CryptoCurrency {
    private typealias LocalizedString = LocalizationConstants.Account

    public var defaultInterestWalletName: String {
        String(format: LocalizedString.myInterestWallet, code)
    }
    public var defaultTradeWalletName: String {
        String(format: LocalizedString.myTradeAccount, code)
    }
    public var defaultWalletName: String {
        String(format: LocalizedString.myWallet, code)
    }
}
