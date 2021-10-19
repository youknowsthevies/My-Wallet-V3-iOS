// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation

extension Effect {

    func mapped<T>(to action: CasePath<T, Output>) -> Effect<T, Failure> {
        map { output in action.embed(output) }
    }

    func mapped<T>(to action: @escaping (Output) -> T) -> Effect<T, Failure> {
        map(action)
    }

    func mapped<T>(to action: @autoclosure @escaping () -> T) -> Effect<T, Failure> {
        map { _ -> T in action() }
    }
}

extension Effect where Output: NavigationAction {

    public static func navigate(to route: Output.RouteType?) -> Self {
        Effect(value: .navigate(to: route))
    }

    public static func enter(into route: Output.RouteType?) -> Self {
        Effect(value: .enter(into: route))
    }
}
