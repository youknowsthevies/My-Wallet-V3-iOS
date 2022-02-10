// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization

struct DoubleButtonAction: Equatable {
    let title: String
    let icon: Icon

    static var buy: Self {
        DoubleButtonAction(
            title: LocalizationConstants.Coin.Button.Title.buy,
            icon: Icon.cart
        )
    }

    static var sell: Self {
        DoubleButtonAction(
            title: LocalizationConstants.Coin.Button.Title.sell,
            icon: Icon.sell
        )
    }

    static var send: Self {
        DoubleButtonAction(
            title: LocalizationConstants.Coin.Button.Title.send,
            icon: Icon.send
        )
    }

    static var receive: Self {
        DoubleButtonAction(
            title: LocalizationConstants.Coin.Button.Title.receive,
            icon: Icon.qrCode
        )
    }
}
