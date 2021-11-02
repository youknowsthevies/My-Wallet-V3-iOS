// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CasePaths
import ComposableArchitecture
import ComposableNavigation
import OpenBankingDomain
import ToolKit

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

extension Reducer where Action: FailureAction {

    init(_ reducer: @escaping (inout State, Action, Environment) throws -> Effect<Action, Never>) {
        self.init { state, action, environment in
            do {
                return try reducer(&state, action, environment)
            } catch {
                return Effect(value: .failure(error))
            }
        }
    }
}

extension Effect where Output: ResultProtocol {

    func mapped<T>(to action: @escaping (Output.Success) -> T) -> Effect<T, Failure> where T: FailureAction {
        map { it -> T in
            switch it.result {
            case .success(let value):
                return action(value)
            case .failure(let error):
                return T.failure(error)
            }
        }
    }

    func mapped<T>(to action: CasePath<T, Output.Success>) -> Effect<T, Failure> where T: FailureAction {
        map { it -> T in
            switch it.result {
            case .success(let value):
                return action.embed(value)
            case .failure(let error):
                return T.failure(error)
            }
        }
    }
}
