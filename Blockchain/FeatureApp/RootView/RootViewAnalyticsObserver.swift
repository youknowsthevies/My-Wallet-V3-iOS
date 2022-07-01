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
            analytics.record(event: .walletHomeViewed)
        },
        app.on(blockchain.ux.prices) { [analytics] _ in
            analytics.record(event: .walletPricesViewed)
        },
        app.on(blockchain.ux.buy_and_sell) { [analytics] _ in
            analytics.record(event: .walletBuySellViewed)
        },
        app.on(blockchain.ux.user.rewards) { [analytics] _ in
            analytics.record(event: .walletRewardsViewed)
        },
        app.on(blockchain.ux.user.activity) { [analytics] _ in
            analytics.record(event: .walletActivityViewed)
        },
        app.on(blockchain.ux.frequent.action) { [analytics] _ in
            analytics.record(event: .walletFABViewed)
        },
        app.on(blockchain.ux.frequent.action.buy) { [analytics] _ in
            analytics.record(event: .buySellClicked(type: "BUY"))
        },
        app.on(blockchain.ux.frequent.action.sell) { [analytics] _ in
            analytics.record(event: .buySellClicked(type: "SELL"))
        },
        app.on(blockchain.ux.frequent.action.rewards) { [analytics] _ in
            analytics.record(event: .interestClicked)
        },
        app.on(blockchain.ux.referral.giftbox) { [analytics] _ in
            analytics.record(event: .walletReferralProgramClicked())
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

extension AnalyticsEvents.New {
    enum WalletAnalyticsEvent: AnalyticsEvent {
        var type: AnalyticsEventType { .nabu }

        case walletActivityViewed
        case walletBuySellViewed
        case walletHomeViewed
        case walletPricesViewed
        case walletRewardsViewed
        case walletFABViewed

        case buySellClicked(type: String, origin: String = "FAB")
    }

    enum ReferralAnalyticsEvent: AnalyticsEvent {
        public var type: AnalyticsEventType { .nabu }

        case walletReferralProgramClicked(origin: String = "portfolio")
    }

    enum InterestAnalyticsEvent: AnalyticsEvent {
        public var type: AnalyticsEventType { .nabu }

        case interestClicked
    }
}

extension AnalyticsEventRecorderAPI {
    func record(event: AnalyticsEvents.New.WalletAnalyticsEvent) {
        record(event: event)
    }

    func record(event: AnalyticsEvents.New.ReferralAnalyticsEvent) {
        record(event: event)
    }

    func record(event: AnalyticsEvents.New.InterestAnalyticsEvent) {
        record(event: event)
    }
}
