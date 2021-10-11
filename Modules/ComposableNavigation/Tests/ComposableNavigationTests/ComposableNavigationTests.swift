import ComposableArchitecture
@testable import ComposableNavigation
import SwiftUI
import XCTest

final class ComposableNavigationTests: XCTestCase {

    func test_route() throws {

        var state = TestState()

        _ = testReducer.run(&state, .navigate(to: .test), ())
        XCTAssertEqual(state.route, RouteIntent(route: .test, action: .navigateTo))

        _ = testReducer.run(&state, .enter(into: .story), ())
        XCTAssertEqual(state.route, RouteIntent(route: .story, action: .enterInto(fullScreen: false)))

        _ = testReducer.run(&state, .route(nil), ())
        XCTAssertNil(state.route)

        _ = testReducer.run(&state, .enter(into: .story, fullScreen: true), ())
        XCTAssertEqual(state.route, RouteIntent(route: .story, action: .enterInto(fullScreen: true)))

        _ = testReducer.run(&state, .route(nil), ())
        XCTAssertNil(state.route)

        _ = testReducer.run(&state, .enter(into: .context("Context")), ())
        XCTAssertEqual(state.route, RouteIntent(route: .context("Context"), action: .enterInto()))
    }
}

struct TestState: NavigationState {
    var route: RouteIntent<TestRoute>?
}

enum TestAction: NavigationAction {
    case route(RouteIntent<TestRoute>?)
}

enum TestRoute: NavigationRoute {

    case test
    case story
    case context(String)

    func destination(in store: Store<TestState, TestAction>) -> some View {
        Text(String(describing: self))
    }
}

let testReducer = Reducer<TestState, TestAction, Void> { state, action, _ in
    switch action {
    case .route(let route):
        state.route = route
        return .none
    }
}
