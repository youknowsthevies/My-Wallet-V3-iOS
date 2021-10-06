// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI

/// An intent of navigation used to determine the route and the action performed to arrive there
public struct RouteIntent<R: NavigationRoute>: Hashable {

    public enum Action {

        /// A navigation action that continues a user-journey by navigating to a new screen.
        case navigateTo

        /// A navigation action that enters a new user journey context, on iOS this will present a modal,
        /// on macOS it will show a new screen and on watchOS it will enter into a new screen entirely.
        case enterInto
    }

    public var value: R
    public var action: Action
}

/// A specfication of a route and how it maps to the destination screen
public protocol NavigationRoute: Hashable {

    associatedtype Destination: View
    associatedtype State: NavigationState where State.RouteType == Self
    associatedtype Action: NavigationAction where Action.RouteType == Self

    func destination(in store: Store<State, Action>) -> Destination

    static var allRoutes: [Self] { get }
}

extension NavigationRoute where Self: CaseIterable {
    public static var allRoutes: AllCases { allCases }
}

/// A piece of state that defines a route
public protocol NavigationState: Equatable {
    associatedtype RouteType: NavigationRoute where RouteType.State == Self
    var route: RouteIntent<RouteType>? { get set }
}

/// An action which can fire a new route intent
public protocol NavigationAction {
    associatedtype RouteType: NavigationRoute where RouteType.Action == Self
    static func route(_ route: RouteIntent<RouteType>?) -> Self
}

extension NavigationRoute {

    public var label: String {
        Mirror(reflecting: self).children.first?.label
            ?? String(describing: self)
    }
}

extension NavigationAction {

    public static func navigate(to route: RouteType?) -> Self {
        .route(route.map { RouteIntent(value: $0, action: .navigateTo) })
    }

    public static func enter(into route: RouteType?) -> Self {
        .route(route.map { RouteIntent(value: $0, action: .enterInto) })
    }
}

extension View {

    @ViewBuilder
    public func navigationRoute<State: NavigationState>(
        in store: Store<State, State.RouteType.Action>
    ) -> some View {
        navigationRoute(State.RouteType.self, in: store)
    }

    @ViewBuilder
    public func navigationRoute<Route: NavigationRoute>(
        _ route: Route.Type = Route.self, in store: Store<Route.State, Route.Action>
    ) -> some View {
        modifier(NavigationRouteViewModifier<Route>(store: store))
    }
}

/// A modifier to create NavigationLink and sheet views ahead of time
public struct NavigationRouteViewModifier<Route: NavigationRoute>: ViewModifier {

    public typealias State = Route.State
    public typealias Action = Route.Action

    public let store: Store<State, Action>

    public func body(content: Content) -> some View {
        content.background(
            WithViewStore(store) { view in
                ForEach(Route.allRoutes, id: \.self) { route in
                    let navigateTo = view.binding(get: \.__navigateTo, send: Action.navigate(to:))
                    NavigationLink(
                        destination: route.destination(in: store),
                        tag: route,
                        selection: navigateTo,
                        label: EmptyView.init
                    )

                    let enterInto = view.binding(get: \.__enterInto, send: Action.enter(into:))
                    EmptyView().sheet(
                        isPresented: Binding(
                            get: { enterInto.wrappedValue == route },
                            set: { enterInto.wrappedValue = $0 ? route : nil }
                        ),
                        content: {
                            NavigationView { route.destination(in: store) }
                        }
                    )
                }
            }
        )
    }
}

extension NavigationState {

    fileprivate var __navigateTo: RouteType? {
        guard let route = route, route.action == .navigateTo else { return nil }
        return route.value
    }

    fileprivate var __enterInto: RouteType? {
        guard let route = route, route.action == .enterInto else { return nil }
        return route.value
    }
}

extension Effect where Output: NavigationAction {

    /// A navigation effect to continue a user-journey by navigating to a new screen.
    public static func navigate(to route: Output.RouteType?) -> Self {
        Effect(value: .navigate(to: route))
    }

    /// A navigation effect that enters a new user journey context.
    public static func enter(into route: Output.RouteType?) -> Self {
        Effect(value: .enter(into: route))
    }
}
