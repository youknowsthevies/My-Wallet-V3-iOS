// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

final class MnemonicAccessMock: MnemonicAccessAPI {

    var underlyingMnemonicMaybe: Maybe<Mnemonic> = .just("")
    var underlyingMnemonicSingle: Single<Mnemonic> = .just("")

    var mnemonic: Maybe<Mnemonic> {
        underlyingMnemonicMaybe
    }

    var mnemonicPromptingIfNeeded: Maybe<Mnemonic> {
        underlyingMnemonicMaybe
    }

    func mnemonic(with secondPassword: String?) -> Single<Mnemonic> {
        underlyingMnemonicSingle
    }
}
