// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI

/// An intent of navigation used to determine the route and the action performed to arrive there
public struct RouteIntent<R: NavigationRoute>: Hashable {

    public enum Action: Hashable {

        /// A navigation action that continues a user-journey by navigating to a new screen.
        case navigateTo

        /// A navigation action that enters a new user journey context, on iOS this will present a modal,
        /// on macOS it will show a new screen and on watchOS it will enter into a new screen entirely.
        case enterInto(fullScreen: Bool = false)
    }

    public var route: R
    public var action: Action
}

/// A specfication of a route and how it maps to the destination screen
public protocol NavigationRoute: Hashable {

    associatedtype Destination: View
    associatedtype State: NavigationState where State.RouteType == Self
    associatedtype Action: NavigationAction where Action.RouteType == Self

    func destination(in store: Store<State, Action>) -> Destination
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
        .route(route.map { RouteIntent(route: $0, action: .navigateTo) })
    }

    public static func enter(into route: RouteType?) -> Self {
        enter(into: route, fullScreen: false)
    }

    public static func enter(into route: RouteType?, fullScreen: Bool) -> Self {
        .route(route.map { RouteIntent(route: $0, action: .enterInto(fullScreen: fullScreen)) })
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
        modifier(NavigationRouteViewModifier<Route>(store))
    }
}

extension Effect where Output: NavigationAction {

    /// A navigation effect to continue a user-journey by navigating to a new screen.
    public static func navigate(to route: Output.RouteType?) -> Self {
        Effect(value: .navigate(to: route))
    }

    /// A navigation effect that enters a new user journey context.
    public static func enter(into route: Output.RouteType?, fullScreen: Bool = false) -> Self {
        Effect(value: .enter(into: route, fullScreen: fullScreen))
    }
}

/// A modifier to create NavigationLink and sheet views ahead of time
public struct NavigationRouteViewModifier<Route: NavigationRoute>: ViewModifier {

    public typealias State = Route.State
    public typealias Action = Route.Action

    public let store: Store<State, Action>
    @SwiftUI.State private var isReady: Set<RouteIntent<Route>> = []

    public init(_ store: Store<State, Action>) {
        self.store = store
    }

    public func body(content: Content) -> some View {
        content.background(
            WithViewStore(store) { viewStore in
                if let intent = viewStore.route {
                    Group {
                        switch intent.action {
                        case .navigateTo:
                            let navigateTo = viewStore.binding(
                                get: \.__navigateTo,
                                send: Action.route
                            )
                            NavigationLink(
                                destination: intent.route.destination(in: store),
                                isActive: Binding(navigateTo, to: intent, isReady: $isReady),
                                label: EmptyView.init
                            )

                        case .enterInto(fullScreen: false):
                            let enterInto = viewStore.binding(
                                get: \.__enterInto,
                                send: Action.route
                            )
                            EmptyView()
                                .sheet(
                                    isPresented: Binding(enterInto, to: intent, isReady: $isReady),
                                    content: {
                                        NavigationView { intent.route.destination(in: store) }
                                    }
                                )

                        case .enterInto(fullScreen: true):
                            let enterIntoFullScreen = viewStore.binding(
                                get: \.__enterIntoFullScreen,
                                send: Action.route
                            )
                            #if os(macOS)
                            EmptyView()
                                .sheet(
                                    isPresented: Binding(enterIntoFullScreen, to: intent, isReady: $isReady),
                                    content: {
                                        NavigationView { intent.route.destination(in: store) }
                                    }
                                )
                            #else
                            EmptyView()
                                .fullScreenCover(
                                    isPresented: Binding(enterIntoFullScreen, to: intent, isReady: $isReady),
                                    content: {
                                        NavigationView { intent.route.destination(in: store) }
                                    }
                                )
                            #endif
                        }
                    }
                    .inserting(intent, into: $isReady)
                }
            }
        )
    }
}

extension View {

    @ViewBuilder fileprivate func inserting<E>(
        _ element: E,
        into binding: Binding<Set<E>>
    ) -> some View where E: Hashable {
        onAppear {
            DispatchQueue.main.async { binding.wrappedValue.insert(element) }
        }
    }
}

extension Binding where Value == Bool {

    fileprivate init<E: Equatable, S: SetAlgebra>(
        _ source: Binding<E?>,
        to element: E,
        isReady ready: Binding<S>
    ) where S.Element == E {
        self.init(
            get: { source.wrappedValue == element && ready.wrappedValue.contains(element) },
            set: { isPresented in
                source.wrappedValue = isPresented ? element : nil
                guard !isPresented else { return }
                ready.wrappedValue.remove(element)
            }
        )
    }
}

extension NavigationState {

    fileprivate var __navigateTo: RouteIntent<RouteType>? {
        guard let intent = route, intent.action == .navigateTo else { return nil }
        return intent
    }

    fileprivate var __enterInto: RouteIntent<RouteType>? {
        guard let intent = route, case .enterInto(false) = intent.action else { return nil }
        return intent
    }

    fileprivate var __enterIntoFullScreen: RouteIntent<RouteType>? {
        guard let intent = route, case .enterInto(true) = intent.action else { return nil }
        return intent
    }
}
