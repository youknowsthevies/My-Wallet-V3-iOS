// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import PlatformKit
import RxSwift

public protocol EthereumWalletAccountBridgeAPI: AnyObject {
    /// Get all ethereum wallets.
    /// There should be only one wallet, but some blockchain wallets have more than one.
    var wallets: AnyPublisher<[EthereumWalletAccount], Error> { get }
}

public protocol EthereumWalletBridgeAPI: AnyObject {
    /// Get transaction note.
    func note(for transactionHash: String) -> Single<String?>

    /// Set transaction note.
    func updateNote(for transactionHash: String, note: String?) -> Completable

    /// Record transaction in metadata.
    func recordLast(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished>

    /// Updates the Ethereum account label at the given index.
    func update(accountIndex: Int, label: String) -> Completable
}
