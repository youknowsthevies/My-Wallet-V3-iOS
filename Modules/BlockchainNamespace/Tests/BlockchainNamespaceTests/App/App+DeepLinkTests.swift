import BlockchainNamespace
import Combine
import XCTest

final class AppDeepLinkTests: XCTestCase {

    var app: App = .init()
    var bag: Set<AnyCancellable> = []
    var count: [Tag: UInt] = [:]

    override func setUp() {
        super.setUp()
        app = .init()
    }

    func test_handle_deep_link() throws {

        app.state.set(blockchain.app.is.ready.for.deep_link, to: true)

        app.on(blockchain.db.type.string)
            .sink { event in self.count[event.tag, default: 0] += 1 }
            .store(in: &bag)

        app.post(
            event: blockchain.app.process.deep_link,
            context: [
                blockchain.app.process.deep_link.url[]: URL(
                    string: "https://blockchain.com/app?blockchain.db.type.string=test#blockchain.db.type.string"
                )!
            ]
        )
        XCTAssertEqual(count[blockchain.db.type.string], 1)
        try XCTAssertAnyEqual(app.state.get(blockchain.db.type.string), "test")
    }

    func test_handle_deep_link_is_deferred_until_ready() throws {

        app.on(blockchain.db.type.string)
            .sink { event in self.count[event.tag, default: 0] += 1 }
            .store(in: &bag)

        app.post(
            event: blockchain.app.process.deep_link,
            context: [
                blockchain.app.process.deep_link.url[]: URL(
                    string: "https://blockchain.com/app?blockchain.db.type.string=test#blockchain.db.type.string"
                )!
            ]
        )

        XCTAssertNil(count[blockchain.db.type.string])
        XCTAssertThrowsError(try app.state.get(blockchain.db.type.string))

        app.state.set(blockchain.app.is.ready.for.deep_link, to: true)

        XCTAssertEqual(count[blockchain.db.type.string], 1)
        try XCTAssertAnyEqual(app.state.get(blockchain.db.type.string), "test")
    }
}
