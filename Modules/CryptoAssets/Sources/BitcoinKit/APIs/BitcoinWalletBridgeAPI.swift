// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Combine
import PlatformKit
import RxSwift

public protocol BitcoinWalletBridgeAPI: AnyObject {

    // MARK: - Wallet Account

    var defaultWallet: Single<BitcoinWalletAccount> { get }

    var wallets: Single<[BitcoinWalletAccount]> { get }

    func note(for transactionHash: String) -> Single<String?>

    func updateNote(for transactionHash: String, note: String?) -> Completable

    func receiveAddress(forXPub xpub: String) -> Single<String>

    func firstReceiveAddress(forXPub xpub: String) -> Single<String>

    func walletIndex(for receiveAddress: String) -> Single<Int32>

    func update(accountIndex: Int, label: String) -> Completable
}
