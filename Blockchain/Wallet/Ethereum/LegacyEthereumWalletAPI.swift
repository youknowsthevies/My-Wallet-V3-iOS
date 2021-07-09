// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxSwift

protocol LegacyEthereumWalletAPI: AnyObject {

    func checkIfEthereumAccountExists() -> Bool

    func ethereumAccounts(with secondPassword: String?, success: @escaping ([[String: Any]]) -> Void, error: @escaping (String) -> Void)
    func getLabelForEthereumAccount(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void)
    func getEthereumAddress(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void)

    func getEthereumMemo(for transaction: String, success: @escaping (String?) -> Void, error: @escaping (String) -> Void)
    func setEthereumMemo(for transaction: String, memo: String?)

    func recordLastEthereumTransaction(transactionHash: String, success: @escaping () -> Void, error: @escaping (String) -> Void)
}
