// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import FeatureCoinDomain
import SwiftUI

public final class CoinViewAnalytics: Session.Observer {

    unowned var app: AppProtocol
    let analytics: AnalyticsEventRecorderAPI

    public init(app: AppProtocol, analytics: AnalyticsEventRecorderAPI) {
        self.app = app
        self.analytics = analytics
        start()
    }

    public func start() {
        for event in events {
            event.start()
        }
    }

    public func stop() {
        for event in events {
            event.stop()
        }
    }

    lazy var events = [
        buy,
        sell,
        receive,
        send,
        explainer,
        website,
        timeInterval,
        transaction,
        accountSheet,
        exchangeConnect,
        kyc
    ]

    lazy var buy = app.on(blockchain.ux.asset.buy) { [analytics] event in
        try analytics.record(
            event: CoinViewAnalyticsEvent(
                name: "Buy Sell Clicked",
                params: [
                    "currency": event.ref.context.decode(blockchain.ux.asset.id) as String,
                    "selection": "BUY"
                ]
            )
        )
    }

    lazy var sell = app.on(blockchain.ux.asset.sell) { [analytics] event in
        try analytics.record(
            event: CoinViewAnalyticsEvent(
                name: "Buy Sell Clicked",
                params: [
                    "currency": event.ref.context.decode(blockchain.ux.asset.id) as String,
                    "selection": "SELL"
                ]
            )
        )
    }

    lazy var receive = app.on(blockchain.ux.asset.receive) { [analytics] event in
        try analytics.record(
            event: CoinViewAnalyticsEvent(
                name: "Buy Receive Clicked",
                params: [
                    "currency": event.ref.context.decode(blockchain.ux.asset.id) as String,
                    "selection": "RECEIVE"
                ]
            )
        )
    }

    lazy var send = app.on(blockchain.ux.asset.send) { [analytics] event in
        try analytics.record(
            event: CoinViewAnalyticsEvent(
                name: "Send Receive Clicked",
                params: [
                    "currency": event.ref.context.decode(blockchain.ux.asset.id) as String,
                    "selection": "SEND"
                ]
            )
        )
    }

    lazy var explainer = app.on(
        blockchain.ux.asset.account.explainer,
        blockchain.ux.asset.account.explainer.accept
    ) { [analytics] event in
        guard let account = event.context[blockchain.ux.asset.account] as? Account.Snapshot else { return }
        try analytics.record(
            event: CoinViewAnalyticsEvent(
                name: event.tag.is(blockchain.ux.asset.account.explainer.accept)
                    ? "Explainer Accepted"
                    : "Explainer Viewed",
                params: [
                    "currency": event.ref.context.decode(blockchain.ux.asset.id) as String,
                    "account_type": account.accountType.analytics
                ]
            )
        )
    }

    lazy var website = app.on(blockchain.ux.asset.bio.visit.website) { [analytics] event in
        guard let account = event.context[blockchain.ux.asset.account] as? Account.Snapshot else { return }
        try analytics.record(
            event: CoinViewAnalyticsEvent(
                name: "Hyperlink Clicked",
                params: [
                    "currency": event.ref.context.decode(blockchain.ux.asset.id) as String,
                    "selection": "OFFICIAL_WEBSITE_WEB"
                ]
            )
        )
    }

    lazy var timeInterval = app.on(blockchain.ux.asset.chart.interval) { [analytics] event in
        guard let series = event.context[blockchain.ux.asset.chart.interval] as? FeatureCoinDomain.Series else {
            return
        }
        try analytics.record(
            event: CoinViewAnalyticsEvent(
                name: "Time Interval Selected",
                params: [
                    "currency": event.ref.context.decode(blockchain.ux.asset.id) as String,
                    "time_interval": series.analytics
                ]
            )
        )
    }

    lazy var transaction = app.on(
        blockchain.ux.asset.account.activity,
        blockchain.ux.asset.account.buy,
        blockchain.ux.asset.account.receive,
        blockchain.ux.asset.account.rewards.summary,
        blockchain.ux.asset.account.rewards.withdraw,
        blockchain.ux.asset.account.rewards.deposit,
        blockchain.ux.asset.account.exchange.withdraw,
        blockchain.ux.asset.account.exchange.deposit,
        blockchain.ux.asset.account.sell,
        blockchain.ux.asset.account.send,
        blockchain.ux.asset.account.swap
    ) { [analytics] event in

        let type = try event.tag.idRemainder(after: blockchain.ux.asset.account[])
            .replacingOccurrences(of: ".", with: "_")
            .uppercased()

        try analytics.record(
            event: CoinViewAnalyticsEvent(
                name: "Transaction Type Clicked",
                params: [
                    "currency": event.ref.context.decode(blockchain.ux.asset.id) as String,
                    "transaction_type": type
                ]
            )
        )
    }

    lazy var accountSheet = app.on(blockchain.ux.asset.account.sheet) { [analytics] event in
        guard let account = event.context[blockchain.ux.asset.account] as? Account.Snapshot else { return }
        try analytics.record(
            events: ["Wallets Accounts Clicked", "Wallets Accounts Viewed"].map { name in
                try CoinViewAnalyticsEvent(
                    name: name,
                    params: [
                        "currency": event.ref.context.decode(blockchain.ux.asset.id) as String,
                        "account_type": account.accountType.analytics
                    ]
                )
            }
        )
    }

    lazy var exchangeConnect = app.on(blockchain.ux.asset.account.exchange.connect) { [analytics] event in
        try analytics.record(
            event: CoinViewAnalyticsEvent(
                name: "Connect To The Exchange Actioned",
                params: [
                    "currency": event.ref.context.decode(blockchain.ux.asset.id) as String
                ]
            )
        )
    }

    lazy var kyc = app.on(blockchain.ux.asset.account.require.KYC) { [analytics] event in
        try analytics.record(
            event: CoinViewAnalyticsEvent(
                name: "Upgrade Verification Clicked",
                params: [
                    "currency": event.ref.context.decode(blockchain.ux.asset.id) as String
                ]
            )
        )
    }
}

extension FeatureCoinDomain.Series {

    fileprivate var analytics: String {
        switch self {
        case ._15_minutes:
            return "LIVE"
        case .day:
            return "1D"
        case .week:
            return "1W"
        case .month:
            return "1M"
        case .year:
            return "1Y"
        case .all:
            return "ALL"
        case _:
            return "NONE"
        }
    }
}

extension Account.AccountType {

    fileprivate var analytics: String {
        switch self {
        case .interest:
            return "REWARDS_ACCOUNT"
        case .trading:
            return "TRADING_ACCOUNT"
        case .privateKey:
            return "USERKEY"
        case .exchange:
            return "EXCHANGE_ACCOUNT"
        }
    }
}

struct CoinViewAnalyticsEvent: AnalyticsEvent {
    var name: String
    var params: [String: Any]?
    init(name: String, params: [String: Any] = [:]) {
        self.name = name
        self.params = [
            "origin": "COIN_VIEW"
        ] + params
    }
}
