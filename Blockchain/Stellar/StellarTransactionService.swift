// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import PlatformKit
import RxSwift
import StellarKit
import stellarsdk

class StellarTransactionService: StellarTransactionAPI {
    
    typealias TransactionResult = StellarTransactionResponse.Result
    typealias StellarAssetType = stellarsdk.AssetType
    typealias StellarTransaction = stellarsdk.Transaction
    
    private var configuration: Single<StellarConfiguration> {
        configurationService.configuration
    }
    
    private var service: Single<stellarsdk.TransactionsService> {
        configuration
            .flatMap { configuration -> Single<stellarsdk.TransactionsService> in
                Single.just(configuration.sdk.transactions)
            }
    }
    
    private let configurationService: StellarConfigurationAPI
    private let accounts: StellarAccountAPI
    private let repository: StellarWalletAccountRepositoryAPI
    private let walletService: WalletOptionsAPI

    private let bag = DisposeBag()

    init(
        configurationService: StellarConfigurationAPI,
        accounts: StellarAccountAPI,
        repository: StellarWalletAccountRepositoryAPI,
        walletService: WalletOptionsAPI = resolve()
    ) {
        self.configurationService = configurationService
        self.accounts = accounts
        self.repository = repository
        self.walletService = walletService
    }

    func send(_ paymentOperation: StellarPaymentOperation, sourceKeyPair: StellarKit.StellarKeyPair) -> Completable {
        let sourceAccount = accounts.accountResponse(for: sourceKeyPair.accountID)
        return Single.zip(walletService.walletOptions, fundAccountIfEmpty(
            paymentOperation,
            sourceKeyPair: sourceKeyPair
        )).flatMapCompletable { [weak self] walletOptions, didFundAccount in
            guard !didFundAccount else {
                return Completable.empty()
            }
            return sourceAccount.flatMapCompletable { accountResponse -> Completable in
                guard let strongSelf = self else {
                    return Completable.never()
                }
                return strongSelf.send(
                    paymentOperation,
                    accountResponse: accountResponse,
                    sourceKeyPair: sourceKeyPair,
                    timeout: walletOptions.xlmMetadata?.sendTimeOutSeconds
                )
            }
        }
    }

    // MARK: - Private

    private func fundAccountIfEmpty(_ paymentOperation: StellarPaymentOperation, sourceKeyPair: StellarKit.StellarKeyPair) -> Single<Bool> {
        accounts.accountResponse(for: paymentOperation.destinationAccountId)
            .map { _ in false }
            .catchError { [weak self] error -> Single<Bool> in
                guard let strongSelf = self else {
                    throw error
                }
                if let stellarError = error as? StellarAccountError, stellarError == .noDefaultAccount {
                    return strongSelf.accounts.fundAccount(
                        paymentOperation.destinationAccountId,
                        amount: paymentOperation.amountInXlm,
                        sourceKeyPair: sourceKeyPair
                    ).andThen(
                        Single.just(true)
                    )
                }
                throw error
            }
    }

    private func send(
        _ paymentOperation: StellarPaymentOperation,
        accountResponse: AccountResponse,
        sourceKeyPair: StellarKit.StellarKeyPair,
        timeout: Int? = nil
    ) -> Completable {
        configuration.flatMap(weak: self) { (self, configuration) -> Single<Void> in
            Single.create(subscribe: { event -> Disposable in
                do {
                    // Assemble objects
                    let source = try KeyPair(secretSeed: sourceKeyPair.secret)
                    let destination = try KeyPair(accountId: paymentOperation.destinationAccountId)
                    let payment = PaymentOperation(
                        sourceAccount: source,
                        destination: destination,
                        asset: Asset(type: StellarAssetType.ASSET_TYPE_NATIVE)!,
                        amount: paymentOperation.amountInXlm
                    )
                    
                    var memo: Memo = .none
                    if let value = paymentOperation.memo {
                        switch value {
                        case .text(let input):
                            memo = .text(input)
                        case .identifier(let input):
                            memo = .id(UInt64(input))
                        }
                    }
                    
                    var timebounds: TimeBounds?
                    let future = Calendar.current.date(
                        byAdding: .second,
                        value: timeout ?? 10,
                        to: Date()
                        )?.timeIntervalSince1970
                    
                    if let value = future {
                        timebounds = try? TimeBounds(
                            minTime: UInt64(0),
                            maxTime: UInt64(value)
                        )
                    }
                    
                    let transaction = try StellarTransaction(
                        sourceAccount: accountResponse,
                        operations: [payment],
                        memo: memo,
                        timeBounds: timebounds
                    )

                    // Sign transaction
                    try transaction.sign(keyPair: source, network: configuration.network)

                    // Perform network operation
                    try configuration.sdk.transactions
                        .submitTransaction(transaction: transaction, response: { response -> (Void) in
                            switch response {
                            case .success(details: _):
                                event(.success(()))
                            case .failure(let error):
                                event(.error(error.toStellarServiceError()))
                            case .destinationRequiresMemo:
                                event(.error(HorizonRequestError.requestFailed(message: "Requires Memo").toStellarServiceError()))
                            }
                        })
                } catch {
                    event(.error(error))
                }
                return Disposables.create()
            })
        }
        .asCompletable()
    }
}
