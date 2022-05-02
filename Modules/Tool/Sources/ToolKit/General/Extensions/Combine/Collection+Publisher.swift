// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

extension Collection where Element: Publisher {

    public func merge() -> Publishers.MergeMany<Element> {
        Publishers.MergeMany(self)
    }
}

extension RandomAccessCollection where Element: Publisher {

    public func zip() -> AnyPublisher<[Element.Output], Element.Failure> {
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
                .zip(self[_1])
                .map { [$0, $1] }
                .eraseToAnyPublisher()
        case 3:
            return self[_0]
                .zip(self[_1], self[_2])
                .map { [$0, $1, $2] }
                .eraseToAnyPublisher()
        case 4:
            return self[_0]
                .zip(self[_1], self[_2], self[_3])
                .map { [$0, $1, $2, $3] }
                .eraseToAnyPublisher()
        default:
            return prefix(4).zip()
                .zip(dropFirst(4).zip())
                .map { $0 + $1 }
                .eraseToAnyPublisher()
        }
    }

    public func combineLatest() -> AnyPublisher<[Element.Output], Element.Failure> {
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

extension RandomAccessCollection where Element: Publisher, Element.Output == Bool {

    /// `FlatMap` all `Publisher`, creating a concatenated stream that returns `true` at first chance.
    public func flatMapConcatFirst() -> AnyPublisher<Element.Output, Element.Failure> {
        reduce(AnyPublisher<Element.Output, Element.Failure>.just(false)) { stream, thisPublisher in
            stream
                .flatMap { result -> AnyPublisher<Element.Output, Element.Failure> in
                    switch result {
                    case true:
                        // If the stream result was true, return.
                        return .just(true)
                    case false:
                        // Else, concatenate stream on the array.
                        return thisPublisher
                            .eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
        }
    }
}
