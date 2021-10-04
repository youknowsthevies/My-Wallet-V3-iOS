// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import Combine

final class SecondPasswordPromptableMock: SecondPasswordPromptable {
    var underlyingSecondPasswordIfNeeded: AnyPublisher<
        String?,
        SecondPasswordError
    > = .just(nil)

    func secondPasswordIfNeeded(
        type: PasswordScreenType
    ) -> AnyPublisher<String?, SecondPasswordError> {
        underlyingSecondPasswordIfNeeded
    }
}
