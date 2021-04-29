// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit
import NetworkKit
import PlatformKit
import RxSwift

public protocol ERC20WalletTranscationsBridgeAPI: class {
    associatedtype Token
    var transactions: Single<[EthereumHistoricalTransaction]> { get }
}

public class AnyERC20HistoricalTransactionService<Token: ERC20Token>: TokenizedHistoricalTransactionAPI {
    
    public typealias Model = ERC20HistoricalTransaction<Token>
    public typealias Bridge = ERC20WalletTranscationsBridgeAPI
    public typealias PageModel = PageResult<Model>

    /// Streams `true` in case the account has at least one transaction
    public var hasTransactions: Single<Bool> {
        fetchTransactions().map { !$0.isEmpty }
    }

    private let accountClient: ERC20AccountAPIClient<Token>
    private let bridge: EthereumWalletBridgeAPI
    
    init(bridge: EthereumWalletBridgeAPI = resolve(),
         accountClient: ERC20AccountAPIClient<Token> = ERC20AccountAPIClient<Token>()) {
        self.bridge = bridge
        self.accountClient = accountClient
    }

    public func fetchTransactions(token: String?, size: Int) -> Single<PageModel> {
        bridge.address
            .flatMap(weak: self) { (self, address) in
                self.fetchTransactions(from: address, page: token ?? "0")
            }
            .map { PageModel(hasNextPage: $0.count >= size, items: $0) }
    }
    
    public func fetchTransactions() -> Single<[ERC20HistoricalTransaction<Token>]> {
        bridge.address
            .flatMap(weak: self) { (self, address) in
                self.fetchTransactions(from: address, page: "0")
            }
    }

    private func fetchTransactions(from address: EthereumAddress, page: String) -> Single<[ERC20HistoricalTransaction<Token>]> {
        accountClient
            .fetchTransactions(from: address.publicKey, page: page)
            .map {
                $0.transactions.map {
                    let direction: Direction = $0.fromAddress == address ? .credit : .debit
                    return $0.make(from: direction)
                }
            }
    }
}
