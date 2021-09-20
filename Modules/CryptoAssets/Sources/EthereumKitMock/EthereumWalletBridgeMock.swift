// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import EthereumKit
import PlatformKit
import RxSwift

final class EthereumWalletAccountBridgeMock: EthereumWalletAccountBridgeAPI {

    var underlyingWallets: AnyPublisher<[EthereumWalletAccount], Error> = .just([])

    var wallets: AnyPublisher<[EthereumWalletAccount], Error> {
        underlyingWallets
    }
}

final class EthereumWalletBridgeMock: EthereumWalletBridgeAPI {

    var underlyingNote: Single<String?> = .just(nil)

    func note(for transactionHash: String) -> Single<String?> {
        underlyingNote
    }

    var underlyingUpdateNote: Completable = .never()

    func updateNote(for transactionHash: String, note: String?) -> Completable {
        underlyingUpdateNote
    }

    var underlyingRecordLast: Single<EthereumTransactionPublished> = .never()

    func recordLast(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished> {
        underlyingRecordLast
    }

    var underlyingUpdate: Completable = .never()

    func update(accountIndex: Int, label: String) -> Completable {
        underlyingUpdate
    }
}
