// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import FeatureTransactionDomain
import PlatformKit
import RxSwift

public protocol EthereumTransactionDispatcherAPI {
    func send(transaction: EthereumTransactionCandidate, secondPassword: String) -> Single<EthereumTransactionPublished>
}

final class EthereumTransactionDispatcher: EthereumTransactionDispatcherAPI {

    private let bridge: EthereumWalletBridgeAPI
    private let keyPairProvider: AnyKeyPairProvider<EthereumKeyPair>
    private let transactionSendingService: EthereumTransactionSendingServiceAPI

    init(
        with bridge: EthereumWalletBridgeAPI = resolve(),
        keyPairProvider: AnyKeyPairProvider<EthereumKeyPair> = resolve(),
        transactionSendingService: EthereumTransactionSendingServiceAPI = resolve()
    ) {
        self.bridge = bridge
        self.keyPairProvider = keyPairProvider
        self.transactionSendingService = transactionSendingService
    }

    func send(transaction: EthereumTransactionCandidate, secondPassword: String) -> Single<EthereumTransactionPublished> {
        keyPairProvider.keyPair(with: secondPassword)
            .flatMap { [transactionSendingService] keyPair -> Single<EthereumTransactionPublished> in
                transactionSendingService.signAndSend(
                    transaction: transaction,
                    keyPair: keyPair
                )
                .asSingle()
            }
            .flatMap { [bridge] transaction -> Single<EthereumTransactionPublished> in
                bridge.recordLast(transaction: transaction)
            }
    }
}
