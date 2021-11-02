// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

extension Publisher where Failure == Never {

    public func sink<Root>(
        to handler: @escaping (Root) -> (Output) -> Void,
        on root: Root
    ) -> AnyCancellable where Root: AnyObject {
        sink { [weak root] value in
            guard let root = root else { return }
            handler(root)(value)
        }
    }

    public func sink<Root>(
        to handler: @escaping (Root) -> () -> Void,
        on root: Root
    ) -> AnyCancellable where Root: AnyObject {
        sink { [weak root] _ in
            guard let root = root else { return }
            handler(root)()
        }
    }
}

extension Publisher {

    public func sink<Root>(
        to handler: @escaping (Root) -> (Output) -> Void,
        on root: Root
    ) -> AnyCancellable where Root: AnyObject {
        sink { _ in } receiveValue: { [weak root] output in
            guard let root = root else { return }
            handler(root)(output)
        }
    }

    public func sink<Root>(
        to handler: @escaping (Root) -> () -> Void,
        on root: Root
    ) -> AnyCancellable where Root: AnyObject {
        sink { _ in } receiveValue: { [weak root] _ in
            guard let root = root else { return }
            handler(root)()
        }
    }

    public func sink<Root>(
        completion completionHandler: @escaping (Root) -> (Subscribers.Completion<Failure>) -> Void,
        receiveValue receiveValueHandler: @escaping (Root) -> (Output) -> Void,
        on root: Root
    ) -> AnyCancellable where Root: AnyObject {
        sink { [weak root] completion in
            guard let root = root else { return }
            completionHandler(root)(completion)
        } receiveValue: { [weak root] output in
            guard let root = root else { return }
            receiveValueHandler(root)(output)
        }
    }
}

extension Publisher {

    public func ignoreOutput<NewOutput>(
        setOutputType newOutputType: NewOutput.Type = NewOutput.self
    ) -> Publishers.Map<Publishers.IgnoreOutput<Self>, NewOutput> {
        ignoreOutput().map { _ -> NewOutput in }
    }

    public func ignoreFailure<NewFailure: Error>(
        setFailureType failureType: NewFailure.Type = NewFailure.self
    ) -> AnyPublisher<Output, NewFailure> {
        `catch` { _ in Empty() }
            .setFailureType(to: failureType)
            .eraseToAnyPublisher()
    }

    public func result() -> AnyPublisher<Result<Output, Failure>, Never> {
        map(Result.success).catch(Result.failure).eraseToAnyPublisher()
    }

    public func `catch`(_ handler: @escaping (Failure) -> Output) -> Publishers.Catch<Self, Just<Output>> {
        `catch` { error in Just(handler(error)) }
    }
}

public protocol ExpressibleByError {
    init<E: Error>(_ error: E)
}

extension Publisher where Output: ResultProtocol {

    public func flatMap<P>(
        maxPublishers: Subscribers.Demand = .unlimited,
        _ transform: @escaping (Output.Success) throws -> P
    ) -> Publishers.FlatMap<AnyPublisher<P.Output, P.Failure>, Self> where
        P: Publisher,
        P.Output: ResultProtocol,
        P.Output.Failure: ExpressibleByError,
        P.Failure == Never
    {
        flatMap(maxPublishers: maxPublishers) { output in
            do {
                switch output.result {
                case .success(let success):
                    return try transform(success).eraseToAnyPublisher()
                case .failure(let error):
                    throw error
                }
            } catch {
                return Just(.failure(.init(error))).eraseToAnyPublisher()
            }
        }
    }
}

extension Publisher {

    public func shareReplay() -> AnyPublisher<Output, Failure> {
        let subject = CurrentValueSubject<Output?, Failure>(nil)
        return map { $0 }
            .multicast(subject: subject)
            .autoconnect()
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}

extension Publisher {

    public func withLatestFrom<Other: Publisher>(
        _ publisher: Other
    ) -> AnyPublisher<Other.Output, Failure> where Other.Failure == Failure {
        withLatestFrom(publisher, selector: { $1 })
    }

    public func withLatestFrom<Other: Publisher, Result>(
        _ other: Other,
        selector: @escaping (Output, Other.Output) -> Result
    ) -> AnyPublisher<Result, Failure> where Other.Failure == Failure {
        let upstream = share()
        return other
            .map { second in upstream.map { selector($0, second) } }
            .switchToLatest()
            .zip(upstream)
            .map(\.0)
            .eraseToAnyPublisher()
    }
}

extension Publisher {

    public func scan() -> AnyPublisher<(newValue: Output, oldValue: Output), Failure> {
        scan(count: 2)
            .map { ($0[1], $0[0]) }
            .eraseToAnyPublisher()
    }

    public func scan(count: Int) -> AnyPublisher<[Output], Failure> {
        scan([]) { ($0 + [$1]).suffix(count) }
            .filter { $0.count == count }
            .eraseToAnyPublisher()
    }
}

extension Publisher where Failure == Never {

    public func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Output?>, on root: Root) -> AnyCancellable {
        map(Output?.init).assign(to: keyPath, on: root)
    }
}

extension Publisher where Failure == Never {

    public func assign(to published: inout Published<Output?>.Publisher) {
        map(Output?.init).assign(to: &published)
    }
}
