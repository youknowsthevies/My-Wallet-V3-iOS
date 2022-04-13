@testable import BlockchainNamespace
import Combine
import FirebaseProtocol
import XCTest

final class AppTests: XCTestCase {

    var app: App = .init()
    var count: [L: Int] = [:]

    var bag: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()

        app = .init()
        count = [:]

        let observations = [
            blockchain.session.event.will.sign.in,
            blockchain.session.event.did.sign.in,
            blockchain.session.event.will.sign.out,
            blockchain.session.event.did.sign.out,
            blockchain.ux.type.analytics.event
        ]

        for event in observations {
            app.on(event)
                .sink { _ in self.count[event, default: 0] += 1 }
                .store(in: &bag)
        }
    }

    func test_pub_sub() {

        app.post(event: blockchain.session.event.will.sign.in)
        app.post(event: blockchain.session.event.did.sign.in)
        app.post(event: blockchain.session.event.will.sign.out)
        app.post(event: blockchain.session.event.did.sign.out)

        XCTAssertEqual(count[blockchain.session.event.will.sign.in], 1)
        XCTAssertEqual(count[blockchain.session.event.did.sign.in], 1)
        XCTAssertEqual(count[blockchain.session.event.will.sign.out], 1)
        XCTAssertEqual(count[blockchain.session.event.did.sign.out], 1)

        XCTAssertEqual(count[blockchain.ux.type.analytics.event], 4)
    }
}

extension App {

    public convenience init(
        language: Language = Language.root.language,
        state: Tag.Context = [:],
        remote: [Mock.RemoteConfigurationSource: [String: Mock.RemoteConfigurationValue]] = [:]
    ) {
        self.init(
            language: language,
            events: .init(),
            state: .init(state),
            remoteConfiguration: Session.RemoteConfiguration(remote: Mock.RemoteConfiguration(remote))
        )
    }
}
