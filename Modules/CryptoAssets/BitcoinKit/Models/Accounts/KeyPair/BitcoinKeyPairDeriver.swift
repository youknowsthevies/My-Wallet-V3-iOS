// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import WalletCore

struct BitcoinPrivateKey: Equatable {
    let xpriv: String

    init(xpriv: String) {
        self.xpriv = xpriv
    }
}

struct BitcoinKeyPair: KeyPair, Equatable {
    let xpub: String
    let privateKey: BitcoinPrivateKey

    init(privateKey: BitcoinPrivateKey, xpub: String) {
        self.privateKey = privateKey
        self.xpub = xpub
    }
}

struct BitcoinKeyDerivationInput: KeyDerivationInput, Equatable {
    let mnemonic: String
    let passphrase: String

    init(mnemonic: String, passphrase: String = "") {
        self.mnemonic = mnemonic
        self.passphrase = passphrase
    }
}

protocol BitcoinKeyPairDeriverAPI: KeyPairDeriverAPI where Input == BitcoinKeyDerivationInput, Pair == BitcoinKeyPair {
    func derive(input: Input) -> Result<Pair, Error>
}

class AnyBitcoinKeyPairDeriver: BitcoinKeyPairDeriverAPI {

    private let deriver: AnyKeyPairDeriver<BitcoinKeyPair, BitcoinKeyDerivationInput>

    // MARK: - Init

    convenience init() {
        self.init(with: BitcoinKeyPairDeriver())
    }

    init<D: KeyPairDeriverAPI>(with deriver: D) where D.Input == BitcoinKeyDerivationInput, D.Pair == BitcoinKeyPair {
        self.deriver = AnyKeyPairDeriver<BitcoinKeyPair, BitcoinKeyDerivationInput>(deriver: deriver)
    }

    func derive(input: BitcoinKeyDerivationInput) -> Result<BitcoinKeyPair, Error> {
        deriver.derive(input: input)
    }
}

class BitcoinKeyPairDeriver: BitcoinKeyPairDeriverAPI {

    func derive(input: BitcoinKeyDerivationInput) -> Result<BitcoinKeyPair, Error> {
        let bitcoinCoinType = CoinType.bitcoin
        let hdwallet = HDWallet(mnemonic: input.mnemonic, passphrase: input.passphrase)
        let privateKey = hdwallet.getExtendedPrivateKey(purpose: .bip44, coin: bitcoinCoinType, version: .xprv)
        let xpub = hdwallet.getExtendedPublicKey(purpose: .bip44, coin: bitcoinCoinType, version: .xpub)
        let bitcoinPrivateKey = BitcoinPrivateKey(xpriv: privateKey)
        let keyPair = BitcoinKeyPair(
            privateKey: bitcoinPrivateKey,
            xpub: xpub
        )
        return .success(keyPair)
    }
}
