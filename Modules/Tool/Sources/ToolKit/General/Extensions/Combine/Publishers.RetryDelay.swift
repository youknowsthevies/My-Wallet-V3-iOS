// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

extension Publisher {

    /// Attempts to recreate a failed subscription with the upstream publisher up to the number of times you specify with
    /// each retry delayed by constant time `delay`
    public func retry<S: Scheduler>(
        _ max: Int = Int.max,
        delay interval: DispatchTimeInterval,
        scheduler: S
    ) -> Publishers.RetryDelay<Self, S> {
        retry(max, delay: .init(interval), scheduler: scheduler)
    }

    /// Attempts to recreate a failed subscription with the upstream publisher up to the number of times you specify with
    /// each retry delayed by ƒ(x) defined by `delay` IntervalDuration
    public func retry<S: Scheduler>(
        _ max: Int = Int.max,
        delay: IntervalDuration,
        scheduler: S
    ) -> Publishers.RetryDelay<Self, S> {
        .init(upstream: self, max: max, delay: delay, scheduler: scheduler)
    }
}

extension Publishers {

    public struct RetryDelay<Upstream: Publisher, S: Scheduler>: Publisher {

        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        public let upstream: Upstream

        public let retries: Int
        public let max: Int
        public let delay: IntervalDuration
        public let scheduler: S

        public init(
            upstream: Upstream,
            retries: Int = 0,
            max: Int,
            delay: IntervalDuration,
            scheduler: S
        ) {
            self.upstream = upstream
            self.retries = retries
            self.max = max
            self.delay = delay
            self.scheduler = scheduler
        }

        public func receive<S: Subscriber>(
            subscriber: S
        ) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            upstream.catch { e -> AnyPublisher<Output, Failure> in
                guard retries < max else { return Fail(error: e).eraseToAnyPublisher() }
                return Fail(error: e)
                    .delay(for: .seconds(delay(retries + 1)), scheduler: scheduler)
                    .catch { _ in
                        RetryDelay(
                            upstream: upstream,
                            retries: retries + 1,
                            max: max,
                            delay: delay,
                            scheduler: scheduler
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .subscribe(subscriber)
        }
    }
}
