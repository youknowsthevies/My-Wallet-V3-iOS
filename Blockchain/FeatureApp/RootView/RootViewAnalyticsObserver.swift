import AnalyticsKit
import BlockchainNamespace

final class RootViewAnalyticsObserver: Session.Observer {

    unowned let app: AppProtocol
    let analytics: AnalyticsEventRecorderAPI

    init(_ app: AppProtocol, analytics: AnalyticsEventRecorderAPI) {
        self.app = app
        self.analytics = analytics
    }

    lazy var observers = [
        app.on(blockchain.ux.user.portfolio) { [analytics] _ in
            analytics.record(event: WalletAnalyticsEvent.walletHomeViewed)
        },
        app.on(blockchain.ux.prices) { [analytics] _ in
            analytics.record(event: WalletAnalyticsEvent.walletPricesViewed)
        },
        app.on(blockchain.ux.buy_and_sell) { [analytics] _ in
            analytics.record(event: WalletAnalyticsEvent.walletBuySellViewed)
        },
        app.on(blockchain.ux.user.rewards) { [analytics] _ in
            analytics.record(event: WalletAnalyticsEvent.walletRewardsViewed)
        },
        app.on(blockchain.ux.user.activity) { [analytics] _ in
            analytics.record(event: WalletAnalyticsEvent.walletActivityViewed)
        },
        app.on(blockchain.ux.frequent.action) { [analytics] _ in
            analytics.record(event: WalletAnalyticsEvent.walletFABViewed)
        },
        app.on(blockchain.ux.frequent.action.buy) { [analytics] _ in
            analytics.record(event: WalletAnalyticsEvent.buySellClicked(type: "BUY"))
        },
        app.on(blockchain.ux.frequent.action.sell) { [analytics] _ in
            analytics.record(event: WalletAnalyticsEvent.buySellClicked(type: "SELL"))
        },
        app.on(blockchain.ux.referral.giftbox) { [analytics] _ in
            analytics.record(event: ReferralAnalyticsEvent.walletReferralProgramClicked())
        }
    ]

    func start() {
        for observer in observers {
            observer.start()
        }
    }

    func stop() {
        for observer in observers {
            observer.stop()
        }
    }
}

enum WalletAnalyticsEvent: AnalyticsEvent {
    case walletActivityViewed
    case walletBuySellViewed
    case walletHomeViewed
    case walletPricesViewed
    case walletRewardsViewed
    case walletFABViewed
    case buySellClicked(type: String, origin: String = "FAB")
}

extension WalletAnalyticsEvent {
    var type: AnalyticsEventType { .nabu }
}

enum ReferralAnalyticsEvent: AnalyticsEvent {
    public var type: AnalyticsEventType { .nabu }
    case walletReferralProgramClicked(source: String = "portfolio")
}
