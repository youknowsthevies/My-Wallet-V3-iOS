// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

// ToolKit/Sources/Extensions/Combine/Publisher.swift
extension Publisher {

    func withLatestFrom<Other: Publisher>(
        _ publisher: Other
    ) -> AnyPublisher<Other.Output, Failure> where Other.Failure == Failure {
        withLatestFrom(publisher, selector: { $1 })
    }

    func withLatestFrom<Other: Publisher, Result>(
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
