// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

extension Publisher where Failure == Never {

    public func task<T>(
        maxPublishers demand: Subscribers.Demand = .unlimited,
        _ yield: @escaping (Output) async -> T
    ) -> AnyPublisher<T, Never> {
        flatMap(maxPublishers: demand) { value -> Task<T, Never>.Publisher in
            Task<T, Never>.Publisher {
                await yield(value)
            }
        }
        .eraseToAnyPublisher()
    }

    public func task<T>(
        maxPublishers demand: Subscribers.Demand = .unlimited,
        _ yield: @escaping (Output) async throws -> T
    ) -> AnyPublisher<T, Error> {
        setFailureType(to: Error.self)
            .flatMap(maxPublishers: demand) { value -> Task<T, Error>.ThrowingPublisher in
                Task<T, Error>.ThrowingPublisher {
                    try await yield(value)
                }
            }
            .eraseToAnyPublisher()
    }
}

extension Publisher {

    public func task<T>(
        maxPublishers demand: Subscribers.Demand = .unlimited,
        _ yield: @escaping (Output) async throws -> T
    ) -> AnyPublisher<T, Error> {
        eraseError()
            .flatMap(maxPublishers: demand) { value -> Task<T, Error>.ThrowingPublisher in
                Task<T, Error>.ThrowingPublisher {
                    try await yield(value)
                }
            }
            .eraseToAnyPublisher()
    }
}

extension Task where Failure == Never {

    public struct Publisher: Combine.Publisher {

        public typealias Output = Success
        public typealias Yield = @Sendable () async -> Output

        private let yield: Yield

        public init(_ yield: @escaping Yield) {
            self.yield = yield
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = Subscription(yield: yield, downstream: subscriber)
            subscriber.receive(subscription: subscription)
        }

        actor Subscription: Combine.Subscription {

            private let yield: Publisher.Yield
            private var downstream: AnySubscriber<Output, Failure>?

            private var task: Task<Void, Never>?

            init<Downstream>(
                yield: @escaping Publisher.Yield,
                downstream: Downstream
            ) where Downstream: Subscriber, Output == Downstream.Input, Downstream.Failure == Failure {
                self.yield = yield
                self.downstream = AnySubscriber(downstream)
            }

            func receive(_ input: Output) {
                _ = downstream?.receive(input)
                downstream?.receive(completion: .finished)
                task = nil
                downstream = nil
            }

            nonisolated func request(_ demand: Subscribers.Demand) {
                Task<Void, Never> { await _request(demand) }
            }

            private func _request(_ demand: Subscribers.Demand) {
                guard demand > 0 else { return }
                guard task == nil else { return }
                task = .detached { [yield, weak self] in
                    let value = await yield()
                    await self?.receive(value)
                }
            }

            nonisolated func cancel() {
                Task<Void, Never> { await _cancel() }
            }

            private func _cancel() {
                task?.cancel()
                task = nil
                downstream = nil
            }
        }
    }
}

extension Task where Failure: Error {

    public struct ThrowingPublisher: Combine.Publisher {

        public typealias Output = Success
        public typealias Yield = @Sendable () async throws -> Output

        private let yield: Yield

        public init(_ yield: @escaping Yield) {
            self.yield = yield
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = Subscription(yield: yield, downstream: subscriber)
            subscriber.receive(subscription: subscription)
        }

        actor Subscription: Combine.Subscription {

            private let yield: ThrowingPublisher.Yield
            private var task: Task<Void, Never>?
            private var downstream: AnySubscriber<Output, Failure>?

            init<Downstream>(
                yield: @escaping ThrowingPublisher.Yield,
                downstream: Downstream
            ) where Downstream: Subscriber, Output == Downstream.Input, Downstream.Failure == Failure {
                self.yield = yield
                self.downstream = AnySubscriber(downstream)
            }

            nonisolated func request(_ demand: Subscribers.Demand) {
                Task<Void, Never> { await _request(demand) }
            }

            func _request(_ demand: Subscribers.Demand) {
                guard demand > 0 else { return }
                guard task == nil else { return }
                task = .detached { [yield, weak self] in
                    do {
                        let value = try await yield()
                        await self?.receive(value)
                    } catch let error as Failure {
                        await self?.receive(error: error)
                    } catch {
                        fatalError("Impossible - expected \(Failure.self), got \(type(of: error))")
                    }
                }
            }

            nonisolated func cancel() {
                Task<Void, Never> { await _cancel() }
            }

            func _cancel() {
                task?.cancel()
                task = nil
                downstream = nil
            }

            private func receive(_ input: Output) {
                _ = downstream?.receive(input)
                downstream?.receive(completion: .finished)
                task = nil
                downstream = nil
            }

            private func receive(error: Failure) {
                _ = downstream?.receive(completion: .failure(error))
                task = nil
                downstream = nil
            }
        }
    }
}
