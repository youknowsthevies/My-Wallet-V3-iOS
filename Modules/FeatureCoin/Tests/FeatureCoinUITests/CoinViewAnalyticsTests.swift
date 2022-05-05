import AnalyticsKit
import BlockchainNamespace
import FeatureCoinDomain
@testable import FeatureCoinUI
import XCTest

final class CoinViewAnalyticsTests: XCTestCase {

    var app: AppProtocol!
    var analytics: AnalyticsEventRecorder!
    var sut: CoinViewAnalytics! {
        didSet { sut?.start() }
    }

    override func setUp() {
        super.setUp()
        app = App.test
        analytics = AnalyticsEventRecorder()
        sut = CoinViewAnalytics(app: app, analytics: analytics)
    }

    override func tearDown() {
        sut.stop()
        super.tearDown()
    }

    func test_open() {
        app.post(event: blockchain.ux.asset["BTC"])
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_chart_selected() {
        app.post(
            event: blockchain.ux.asset["BTC"].chart.selected,
            context: [blockchain.ux.asset.chart.interval: Series.week]
        )
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_chart_deselected() {
        app.post(
            event: blockchain.ux.asset["BTC"].chart.deselected,
            context: [blockchain.ux.asset.chart.interval: Series.week]
        )
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_chart_interval() {
        app.post(value: Series.week, of: blockchain.ux.asset["BTC"].chart.interval)
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_buy() {
        app.post(event: blockchain.ux.asset["BTC"].buy)
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_sell() {
        app.post(event: blockchain.ux.asset["BTC"].sell)
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_receive() {
        app.post(event: blockchain.ux.asset["BTC"].receive)
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_send() {
        app.post(event: blockchain.ux.asset["BTC"].send)
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_explainer() {
        app.post(
            event: blockchain.ux.asset["BTC"].account["Trading"].explainer,
            context: [blockchain.ux.asset.account: Account.Snapshot.preview.trading]
        )
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_explainer_accept() {
        app.post(
            event: blockchain.ux.asset["BTC"].account["Trading"].explainer.accept,
            context: [blockchain.ux.asset.account: Account.Snapshot.preview.trading]
        )
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_website() {
        app.post(event: blockchain.ux.asset["BTC"].bio.visit.website)
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_account_sheet() {
        app.post(
            event: blockchain.ux.asset["BTC"].account["Trading"].sheet,
            context: [blockchain.ux.asset.account: Account.Snapshot.preview.trading]
        )
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_exchange_connect() {
        app.post(event: blockchain.ux.asset["BTC"].account["Trading"].exchange.connect)
        XCTAssertTrue(analytics.session.isNotEmpty)
    }

    func test_transaction() {

        let events: [Tag.Event] = [
            blockchain.ux.asset["BTC"].account["Trading"].activity,
            blockchain.ux.asset["BTC"].account["Trading"].buy,
            blockchain.ux.asset["BTC"].account["Trading"].receive,
            blockchain.ux.asset["BTC"].account["Trading"].rewards.summary,
            blockchain.ux.asset["BTC"].account["Trading"].rewards.withdraw,
            blockchain.ux.asset["BTC"].account["Trading"].rewards.deposit,
            blockchain.ux.asset["BTC"].account["Trading"].exchange.withdraw,
            blockchain.ux.asset["BTC"].account["Trading"].exchange.deposit,
            blockchain.ux.asset["BTC"].account["Trading"].sell,
            blockchain.ux.asset["BTC"].account["Trading"].send,
            blockchain.ux.asset["BTC"].account["Trading"].swap
        ]

        for event in events {
            app.post(event: event, context: [blockchain.ux.asset.account: Account.Snapshot.preview.trading])
        }

        XCTAssertEqual(analytics.session.count, events.count)
    }

    func test_watchlist() {
        app.post(event: blockchain.ux.asset["BTC"].watchlist.add)
        XCTAssertEqual(analytics.session.count, 1)
        app.post(event: blockchain.ux.asset["BTC"].watchlist.remove)
        XCTAssertEqual(analytics.session.count, 2)
    }
}

class AnalyticsEventRecorder: AnalyticsEventRecorderAPI {
    var session: [AnalyticsEvent] = []
    func record(event: AnalyticsEvent) { session.append(event) }
}
