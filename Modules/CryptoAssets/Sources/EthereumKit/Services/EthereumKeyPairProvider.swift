// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit
import WalletPayloadKit

final class EthereumKeyPairProvider: KeyPairProviderAPI {

    // MARK: - KeyPairProviderAPI

    func keyPair(with secondPassword: String?) -> Single<EthereumKeyPair> {
        mnemonicAccess
            .mnemonic(with: secondPassword)
            .asObservable()
            .take(1)
            .asSingle()
            .flatMap(weak: self) { (self, mnemonic) -> Single<EthereumKeyPair> in
                self.deriver.derive(
                    input: EthereumKeyDerivationInput(
                        mnemonic: mnemonic
                    )
                )
                .single
            }
    }

    var keyPair: Single<EthereumKeyPair> {
        mnemonicAccess
            .mnemonicPromptingIfNeeded
            .asObservable()
            .take(1)
            .asSingle()
            .flatMap(weak: self) { (self, mnemonic) -> Single<EthereumKeyPair> in
                self.deriver.derive(
                    input: EthereumKeyDerivationInput(
                        mnemonic: mnemonic
                    )
                )
                .single
            }
    }

    // MARK: - Private Properties

    private let mnemonicAccess: MnemonicAccessAPI
    private let deriver: AnyEthereumKeyPairDeriver

    // MARK: - Init

    init(
        mnemonicAccess: MnemonicAccessAPI = resolve(),
        deriver: AnyEthereumKeyPairDeriver = AnyEthereumKeyPairDeriver(deriver: EthereumKeyPairDeriver())
    ) {
        self.mnemonicAccess = mnemonicAccess
        self.deriver = deriver
    }
}
