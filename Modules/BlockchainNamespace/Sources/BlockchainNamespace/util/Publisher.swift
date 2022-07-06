import Combine

extension Publisher {

    public func stream(
        bufferingPolicy: AsyncThrowingStream<Output, Error>.Continuation.BufferingPolicy = .bufferingNewest(1)
    ) -> AsyncThrowingStream<Output, Error> {
        AsyncThrowingStream(bufferingPolicy: bufferingPolicy) { continuation in
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

    public func stream(
        bufferingPolicy: AsyncStream<Output>.Continuation.BufferingPolicy = .bufferingNewest(1)
    ) -> AsyncStream<Output> {
        AsyncStream(bufferingPolicy: bufferingPolicy) { continuation in
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

extension RandomAccessCollection where Element: Publisher {

    func combineLatest() -> AnyPublisher<[Element.Output], Element.Failure> {
        switch count {
        case 0:
            return Just([])
                .setFailureType(to: Element.Failure.self)
                .eraseToAnyPublisher()
        case 1:
            return self[_0]
                .map { [$0] }
                .eraseToAnyPublisher()
        case 2:
            return self[_0]
                .combineLatest(self[_1])
                .map { [$0, $1] }
                .eraseToAnyPublisher()
        case 3:
            return self[_0]
                .combineLatest(self[_1], self[_2])
                .map { [$0, $1, $2] }
                .eraseToAnyPublisher()
        case 4:
            return self[_0]
                .combineLatest(self[_1], self[_2], self[_3])
                .map { [$0, $1, $2, $3] }
                .eraseToAnyPublisher()
        default:
            return prefix(4).combineLatest()
                .combineLatest(dropFirst(4).combineLatest())
                .map { $0 + $1 }
                .eraseToAnyPublisher()
        }
    }

    private var _0: Index { startIndex }
    private var _1: Index { index(after: startIndex) }
    private var _2: Index { index(after: _1) }
    private var _3: Index { index(after: _2) }
}
