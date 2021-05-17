// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import EthereumKit
import PlatformKit
import RxSwift

public protocol ERC20API {
    associatedtype Token: ERC20Token

    func transfer(to: EthereumAddress, amount cryptoValue: ERC20TokenValue<Token>) -> Single<EthereumTransactionCandidate>

    func transfer(to: EthereumAddress,
                  amount cryptoValue: ERC20TokenValue<Token>,
                  fee: EthereumTransactionFee) -> Single<EthereumTransactionCandidate>

    func transfer(proposal: ERC20TransactionProposal<Token>, to address: EthereumAddress) -> Single<EthereumTransactionCandidate>
}

public protocol ERC20TransactionEvaluationAPI {
    associatedtype Token: ERC20Token

    func evaluate(amount cryptoValue: ERC20TokenValue<Token>) -> Single<ERC20TransactionEvaluationResult<Token>>

    func evaluate(amount cryptoValue: ERC20TokenValue<Token>, fee: EthereumTransactionFee) -> Single<ERC20TransactionEvaluationResult<Token>>
}

public protocol ERC20TransactionMemoAPI {
    associatedtype Token: ERC20Token

    func memo(for transactionHash: String) -> Single<String?>
    func save(transactionMemo: String, for transactionHash: String) -> Single<Void>
}

public protocol ERC20WalletAPI {
    associatedtype Token: ERC20Token

    var tokenAccount: Single<ERC20TokenAccount?> { get }
}
