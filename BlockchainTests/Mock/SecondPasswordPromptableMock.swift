// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import RxSwift

final class SecondPasswordPromptableMock: SecondPasswordPromptable {
    var underlyingSecondPasswordIfNeeded: Single<String?> = .just(nil)

    func secondPasswordIfNeeded(type: PasswordScreenType) -> Single<String?> {
        underlyingSecondPasswordIfNeeded
    }
}
