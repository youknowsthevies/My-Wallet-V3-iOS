import ComposableArchitecture
@testable import ComposableNavigation
import SwiftUI
import XCTest

final class ComposableNavigationTests: XCTestCase {

    func test_route() throws {

        var state = TestState()

        _ = testReducer.run(&state, .navigate(to: .test), ())
        XCTAssertEqual(state.route, RouteIntent(value: .test, action: .navigateTo))

        _ = testReducer.run(&state, .enter(into: .story), ())
        XCTAssertEqual(state.route, RouteIntent(value: .story, action: .enterInto))
    }
}

struct TestState: NavigationState {
    var route: RouteIntent<TestRoute>?
}

enum TestAction: NavigationAction {
    case route(RouteIntent<TestRoute>?)
}

enum TestRoute: String, NavigationRoute, CaseIterable {

    case test
    case story

    func destination(in store: Store<TestState, TestAction>) -> some View {
        Text(rawValue)
    }
}

let testReducer = Reducer<TestState, TestAction, Void> { state, action, _ in
    switch action {
    case .route(let route):
        state.route = route
        return .none
    }
}
