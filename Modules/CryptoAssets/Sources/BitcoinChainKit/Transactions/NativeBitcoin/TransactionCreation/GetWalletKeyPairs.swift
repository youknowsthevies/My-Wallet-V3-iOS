// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit
import ToolKit
import WalletCore
import WalletPayloadKit

func getWalletKeyPairs(
    unspentOutputs: [UnspentOutput],
    accountKeyContext: AccountKeyContext
) -> [WalletKeyPair] {
    unspentOutputs
        .map { utxo -> (UnspentOutput, WalletCoreKeyPair) in
            let walletCoreKeyPair = walletCoreKeyPair(
                for: utxo,
                context: accountKeyContext
            )
            return (utxo, walletCoreKeyPair)
        }
        .map { utxo, walletCoreKeyPair -> WalletKeyPair in
            WalletKeyPair(
                xpriv: walletCoreKeyPair.xpriv,
                privateKeyData: walletCoreKeyPair.privateKeyData,
                xpub: XPub(
                    address: walletCoreKeyPair.xpub,
                    derivationType: utxo.isSegwit ? .bech32 : .legacy
                )
            )
        }
}

public struct WalletCoreKeyPair {

    public var privateKeyData: Data {
        privateKey.data
    }

    public let privateKey: WalletCore.PrivateKey
    public let xpriv: String
    public let xpub: String

    public init(
        privateKey: PrivateKey,
        xpriv: String,
        xpub: String
    ) {
        self.privateKey = privateKey
        self.xpriv = xpriv
        self.xpub = xpub
    }
}

private func walletCoreKeyPair(
    for unspentOutput: UnspentOutput,
    context: AccountKeyContext
) -> WalletCoreKeyPair {
    let childKeyPath = derivationPath(
        for: unspentOutput
    )
    let unspentOutputIsSegWit = unspentOutput.isSegwit
    let derivation = context.derivations.all
        .first(where: { derivation in
            derivation.type.isSegwit == unspentOutputIsSegWit
        })!
    let key = derivation.childKey(with: childKeyPath)
    let xpriv = derivation.xpriv
    let xpub = derivation.xpub
    return WalletCoreKeyPair(
        privateKey: key,
        xpriv: xpriv,
        xpub: xpub
    )
}

private func derivationPath(
    for unspentOutput: UnspentOutput
) -> [WalletCore.DerivationPath.Index] {
    let path = unspentOutput.xpub.path.removing(prefix: "M/")
    let pathComponents = path.split(separator: "/")
    return pathComponents
        .map { component -> WalletCore.DerivationPath.Index in
            let isHardened = component.contains("'")
            let value = UInt32(component.replacingOccurrences(of: "'", with: ""))!
            return WalletCore.DerivationPath.Index(value, hardened: isHardened)
        }
}
