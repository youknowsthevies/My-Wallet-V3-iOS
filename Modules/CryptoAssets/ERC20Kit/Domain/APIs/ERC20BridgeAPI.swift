// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import EthereumKit
import PlatformKit
import RxSwift

public protocol ERC20BridgeAPI: class {
    var isWaitingOnTransaction: Single<Bool> { get }

    var erc20TokenAccounts: Single<[String: ERC20TokenAccount]> { get }

    func tokenAccount(for key: String) -> Single<ERC20TokenAccount?>
    func save(erc20TokenAccounts: [String: ERC20TokenAccount]) -> Single<Void>
    func memo(for transactionHash: String, tokenKey: String) -> Single<String?>
    func save(transactionMemo: String, for transactionHash: String, tokenKey: String) -> Single<Void>
}
