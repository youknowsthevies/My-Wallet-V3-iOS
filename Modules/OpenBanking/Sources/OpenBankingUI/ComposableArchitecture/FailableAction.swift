// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import OpenBanking
import ToolKit

protocol FailableAction {
    static func fail(_ error: OpenBanking.Error) -> Self
}

extension FailableAction {
    static func fail(_ error: Error) -> Self { fail(.init(error)) }
}

extension Reducer where Action: FailableAction {

    init(_ reducer: @escaping (inout State, Action, Environment) throws -> Effect<Action, Never>) {
        self.init { state, action, environment in
            do {
                return try reducer(&state, action, environment)
            } catch {
                return Effect(value: .fail(error))
            }
        }
    }
}

extension Effect where Output: ResultProtocol {

    func mapped<T>(to action: @escaping (Output.Success) -> T) -> Effect<T, Failure> where T: FailableAction {
        map { it -> T in
            switch it.result {
            case .success(let value):
                return action(value)
            case .failure(let error):
                return T.fail(error)
            }
        }
    }

    func mapped<T>(to action: CasePath<T, Output.Success>) -> Effect<T, Failure> where T: FailableAction {
        map { it -> T in
            switch it.result {
            case .success(let value):
                return action.embed(value)
            case .failure(let error):
                return T.fail(error)
            }
        }
    }
}
