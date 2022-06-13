import Combine

extension Publisher {

    public typealias BufferingPolicy = AsyncStream<Output>.Continuation.BufferingPolicy

    public func stream(bufferingPolicy: BufferingPolicy = .bufferingNewest(1)) -> AsyncThrowingStream<Output, Error> {
        AsyncThrowingStream { continuation in
            var cancellable: AnyCancellable?
            let onTermination = { cancellable?.cancel() }

            continuation.onTermination = { @Sendable _ in
                onTermination()
            }

            cancellable = sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        continuation.finish()
                    case .failure(let error):
                        continuation.finish(throwing: error)
                    }
                }, receiveValue: { value in
                    continuation.yield(value)
                }
            )
        }
    }
}

extension Publisher where Failure == Never {

    public func stream(bufferingPolicy: BufferingPolicy = .bufferingNewest(1)) -> AsyncStream<Output> {
        AsyncStream { continuation in
            var cancellable: AnyCancellable?
            let onTermination = { cancellable?.cancel() }

            continuation.onTermination = { @Sendable _ in
                onTermination()
            }

            cancellable = sink(
                receiveCompletion: { _ in
                    continuation.finish()
                }, receiveValue: { value in
                    continuation.yield(value)
                }
            )
        }
    }
}
