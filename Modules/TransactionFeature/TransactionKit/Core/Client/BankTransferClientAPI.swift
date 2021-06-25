// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit
import PlatformKit
import RxSwift

protocol BankTransferClientAPI {

    // MARK: - Combine

    func startBankTransfer(id: String, amount: MoneyValue) -> AnyPublisher<BankTranferPaymentResponse, NetworkError>
    func createWithdrawOrder(id: String, amount: MoneyValue) -> AnyPublisher<Never, NetworkError>

    // MARK: - Rx

    func startBankTransfer(id: String, amount: MoneyValue) -> Single<BankTranferPaymentResponse>
    func createWithdrawOrder(id: String, amount: MoneyValue) -> Completable
}
