// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Localization

struct ButtonAction: Equatable {

    let title: String
    let icon: Icon
    let event: L

    static var buy: Self {
        ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.buy,
            icon: Icon.cart,
            event: blockchain.ux.asset.buy
        )
    }

    static var sell: Self {
        ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.sell,
            icon: Icon.sell,
            event: blockchain.ux.asset.sell
        )
    }

    static var send: Self {
        ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.send,
            icon: Icon.send,
            event: blockchain.ux.asset.send
        )
    }

    static var receive: Self {
        ButtonAction(
            title: LocalizationConstants.Coin.Button.Title.receive,
            icon: Icon.qrCode,
            event: blockchain.ux.asset.receive
        )
    }
}
