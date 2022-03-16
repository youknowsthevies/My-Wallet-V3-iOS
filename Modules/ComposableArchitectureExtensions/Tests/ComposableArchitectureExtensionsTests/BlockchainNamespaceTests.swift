@testable import BlockchainNamespace
import ComposableArchitectureExtensions
import FirebaseProtocol
import XCTest

final class BlockchainNamespaceTests: XCTestCase {

    var app: AppProtocol!

    override func setUp() {
        super.setUp()
        app = App(remote: Mock.RemoteConfiguration())
    }

    func test() {

        let store = TestStore(
            initialState: TestState(),
            reducer: testReducer,
            environment: TestEnvironment(app: app)
        )

        app.post(event: blockchain.db.type.string)
        app.post(event: blockchain.db.type.integer)

        store.send(.observation(.start))

        app.post(event: blockchain.db.type.tag)

        app.post(event: blockchain.db.type.string)
        store.receive(
            .observation(
                .on(blockchain.db.type.string)
            )
        ) { state in
            state.event = blockchain.db.type.string[].ref
            state.context = [:]
        }

        store.send(.post(event: blockchain.db.type.boolean))
        store.receive(
            .observation(
                .on(blockchain.db.type.boolean)
            )
        ) { state in
            state.event = blockchain.db.type.boolean[].ref
            state.context = [:]
        }

        store.send(
            .post(
                event: blockchain.db.type.integer,
                context: [blockchain.db.type.string: "context"]
            )
        )
        store.receive(
            .observation(
                .on(
                    blockchain.db.type.integer,
                    context: [blockchain.db.type.string: "context"]
                )
            )
        ) { state in
            state.event = blockchain.db.type.integer[].ref
            state.context = [blockchain.db.type.string[]: "context"]
        }

        store.send(.observation(.stop))

        app.post(event: blockchain.db.type.boolean)
    }
}

struct TestEnvironment: BlockchainNamespaceAppEnvironment {
    var app: AppProtocol
}

struct TestState: Equatable {
    var event: Tag.Reference?
    var context: [Tag: Anything]?
}

enum TestAction: BlockchainNamespaceObservationAction, BlockchainNamespacePostAction, Equatable {
    case observation(BlockchainNamespaceObservation)
    case post(Tag.Reference, context: Tag.Reference.Context.Equatable = [:])
}

let testReducer = Reducer<TestState, TestAction, TestEnvironment> { state, action, _ in
    switch action {
    case .observation(.event(let event, context: let context)):
        state.event = event
        state.context = context
        return .none
    case .post, .observation:
        return .none
    }
}
.on(blockchain.db.type.string)
.on(blockchain.db.type.integer)
.on(blockchain.db.type.boolean)
.autopost()
