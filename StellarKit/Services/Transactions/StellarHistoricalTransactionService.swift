//
//  StellarHistoricalTransactionService.swift
//  StellarKit
//
//  Created by Alex McGregor on 5/11/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import stellarsdk

final class StellarHistoricalTransactionService: TokenizedHistoricalTransactionAPI {
    
    typealias PageModel = PageResult<StellarHistoricalTransaction>
    
    // MARK: - Private Properties
    
    private var operationService: Single<stellarsdk.OperationsService> {
        sdk.map { $0.operations }
    }

    private var sdk: Single<stellarsdk.StellarSDK> {
        configurationService
            .configuration
            .map { $0.sdk }
    }
    
    // MARK: - Private Properties
    
    private let configurationService: StellarConfigurationAPI
    private let repository: StellarWalletAccountRepositoryAPI
    private let disposeBag = DisposeBag()
    
    init(configurationService: StellarConfigurationAPI = StellarConfigurationService.shared,
         repository: StellarWalletAccountRepositoryAPI) {
        self.configurationService = configurationService
        self.repository = repository
    }
    
    func fetchTransactions(token: String?, size: Int) -> Single<PageModel> {
        guard let accountID = repository.defaultAccount?.publicKey else {
            return Single.error(StellarAccountError.noDefaultAccount)
        }
        return fetchTransactions(accountId: accountID, size: size, token: nil)
    }

    private func fetch(transaction hash: String,
                       accountId: String,
                       operationService: stellarsdk.OperationsService) -> Single<StellarHistoricalTransaction> {
        Single<OperationResponse>
            .create { observer -> Disposable in
                operationService
                    .getOperationDetails(
                        operationId: hash,
                        join: "transactions",
                        response: { response in
                            switch response {
                            case .success(let details):
                                observer(.success(details))
                            case .failure(let error):
                                observer(.error(error))
                            }
                        }
                    )
                return Disposables.create()
            }
            .map { $0.buildOperation(accountID: accountId) }
            .onNil(error: stellarsdk.HorizonRequestError.parsingResponseFailed(message: ""))
    }
    
    private func fetchTransactions(accountId: String, size: Int, token: String?) -> Single<PageModel> {
        operationService
            .flatMap(weak: self) { (self, operationsService) -> Single<PageModel> in
                self.fetchTransactions(
                    accountId: accountId,
                    operationService: operationsService,
                    size: size,
                    token: token
                )
            }
    }
    
    private func fetchTransactions(accountId: String,
                                   operationService: stellarsdk.OperationsService,
                                   size: Int,
                                   token: String?) -> Single<PageModel> {
        Single<PageResponse<OperationResponse>>
            .create { observer -> Disposable in
                operationService.getOperations(
                    forAccount: accountId,
                    from: token,
                    order: .descending,
                    limit: size,
                    join: "transactions",
                    response: { response in
                        switch response {
                        case .success(details: let payload):
                            observer(.success(payload))
                        case .failure(error: let horizonError):
                            observer(.error(horizonError.toStellarServiceError()))
                        }

                })
                return Disposables.create()
            }
            .map { payload -> PageModel in
                let hasNextPage = (payload.hasNextPage() && payload.records.count > 0)
                let transactions = payload
                    .records
                    .compactMap { $0.buildOperation(accountID: accountId) }
                return PageModel(hasNextPage: hasNextPage, items: transactions)
            }
    }
}

extension StellarHistoricalTransactionService: HistoricalTransactionDetailsAPI {
    public func transaction(identifier: String) -> Observable<StellarHistoricalTransaction> {
        guard let accountID = repository.defaultAccount?.publicKey else {
            return .error(StellarAccountError.noDefaultAccount)
        }
        return operationService
            .flatMap(weak: self) { (self, operationService) in
                self.fetch(transaction: identifier, accountId: accountID, operationService: operationService)
            }
            .asObservable()
    }
}

fileprivate extension OperationResponse {
    func buildOperation(accountID: String) -> StellarHistoricalTransaction? {
        guard let transaction = transaction else {
            return nil
        }

        switch operationType {
        case .accountCreated:
            guard let self = self as? AccountCreatedOperationResponse else {
                return nil
            }
            let data = self.accountCreated(accountID: accountID,
                                           feeCharged: transaction.feeCharged,
                                           memo: transaction.memo?.textMemo)
            return .accountCreated(data)

        case .payment:
            guard let self = self as? PaymentOperationResponse else {
                return nil
            }
            let data = self.payment(accountID: accountID,
                                    feeCharged: transaction.feeCharged,
                                    memo: transaction.memo?.textMemo)
            return .payment(data)

        case .accountMerge,
             .allowTrust,
             .bumpSequence,
             .changeTrust,
             .createPassiveSellOffer,
             .inflation,
             .manageBuyOffer,
             .manageData,
             .manageSellOffer,
             .pathPayment,
             .pathPaymentStrictSend,
             .setOptions:
            return nil
        }
    }
}

fileprivate extension AccountCreatedOperationResponse {
    func accountCreated(accountID: String, feeCharged: Int?, memo: String?) -> StellarHistoricalTransaction.AccountCreated {
        StellarHistoricalTransaction.AccountCreated(
            identifier: id,
            funder: funder,
            account: account,
            direction: funder == accountID ? .credit : .debit,
            balance: startingBalance,
            token: pagingToken,
            sourceAccountID: sourceAccount,
            transactionHash: transactionHash,
            createdAt: createdAt,
            fee: funder == accountID ? feeCharged : nil,
            memo: memo
        )
    }
}

fileprivate extension PaymentOperationResponse {
    func payment(accountID: String, feeCharged: Int?, memo: String?) -> StellarHistoricalTransaction.Payment {
        StellarHistoricalTransaction.Payment(
            token: pagingToken,
            identifier: id,
            fromAccount: from,
            toAccount: to,
            direction: from == accountID ? .credit : .debit,
            amount: amount,
            transactionHash: transactionHash,
            createdAt: createdAt,
            fee: from == accountID ? feeCharged : nil,
            memo: memo
        )
    }
}

fileprivate extension stellarsdk.Memo {
    var textMemo: String? {
        switch self {
        case .text(let text):
            return text
        case .hash, .id, .none, .returnHash:
            return nil
        }
    }
}
