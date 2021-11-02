// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public protocol FailureAction {
    static func failure(_ error: OpenBanking.Error) -> Self
}

extension FailureAction {
    public static func failure(_ error: Error) -> Self { failure(.init(error)) }
}
