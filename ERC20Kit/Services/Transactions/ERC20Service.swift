//
//  ERC20Service.swift
//  ERC20Kit
//
//  Created by Jack on 19/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import DIKit
import EthereumKit
import PlatformKit
import RxSwift
import web3swift

public protocol ERC20EvaluationError: Error { }

public enum ERC20ValidationError: TransactionValidationError, ERC20EvaluationError {
    case pendingTransaction
    case invalidCryptoValue
    case cryptoValueBelowMinimumSpendable
    case insufficientEthereumBalance
    case insufficientTokenBalance
}

public enum ERC20ServiceError: ERC20EvaluationError {
    case invalidEthereumAddress
}

public protocol ERC20ServiceAPI {
    associatedtype Token: ERC20Token
    
    func evaluate(amount cryptoValue: ERC20TokenValue<Token>) -> Single<ERC20TransactionEvaluationResult<Token>>
    func transfer(to: EthereumKit.EthereumAddress, amount cryptoValue: ERC20TokenValue<Token>) -> Single<EthereumTransactionCandidate>
}

public class AnyERC20Service<Token: ERC20Token>: ERC20ServiceAPI, ValidateTransactionAPI {
    
    private let evaluateAmount: (ERC20TokenValue<Token>) -> Single<ERC20TransactionEvaluationResult<Token>>
    private let transfer: (EthereumKit.EthereumAddress, ERC20TokenValue<Token>) -> Single<EthereumTransactionCandidate>
    
    public init<S: ERC20ServiceAPI>(_ service: S) where S.Token == Token {
        self.evaluateAmount = service.evaluate
        self.transfer = service.transfer
    }
    
    public func validateCryptoAmount(amount: CryptoMoney) -> Single<TransactionValidationResult> {
        do {
            let value = try ERC20TokenValue<Token>(crypto: amount)
            return evaluate(amount: value)
                .map { _ in .ok }
                .catchError { (error) -> Single<TransactionValidationResult> in
                    guard let validation = error as? TransactionValidationError else {
                        throw error
                    }
                    return Single.just(.invalid(validation))
            }
        } catch {
            return Single.error(error)
        }
    }
    
    public func evaluate(amount cryptoValue: ERC20TokenValue<Token>) -> Single<ERC20TransactionEvaluationResult<Token>> {
        evaluateAmount(cryptoValue)
    }
    
    public func transfer(to: EthereumKit.EthereumAddress, amount cryptoValue: ERC20TokenValue<Token>) -> Single<EthereumTransactionCandidate> {
        transfer(to, cryptoValue)
    }
}

public class ERC20Service<Token: ERC20Token>: ERC20API, ERC20TransactionEvaluationAPI {
    
    enum ERC20ContractMethod: String {
        case transfer
    }
    
    private struct ValidationInputs {
        let value: ERC20TokenValue<Token>
        let fee: EthereumTransactionFee
        let tokenAccountDetails: ERC20AssetAccountDetails
        let ethereumAccountDetails: EthereumAssetAccountDetails
    }
    
    private struct ValidatedInputs {
        let value: ERC20TokenValue<Token>
        let fee: EthereumTransactionFee
        let tokenAccountDetails: ERC20AssetAccountDetails
        let ethereumAccountDetails: EthereumAssetAccountDetails
    }
    
    private var handlePendingTransaction: Single<Void> {
        bridge.isWaitingOnTransaction
            .flatMap { isWaiting -> Single<Void> in
                guard !isWaiting else {
                    throw ERC20ValidationError.pendingTransaction
                }
                return Single.just(())
            }
    }
    
    private var tokenAssetAccountDetails: Single<ERC20AssetAccountDetails> {
        assetAccountRepository.assetAccountDetails.asObservable().asSingle()
    }
    
    private var ethereumAssetAccountDetails: Single<EthereumAssetAccountDetails> {
        ethereumAssetAccountRepository.assetAccountDetails.asObservable().asSingle()
    }
    
    private let bridge: ERC20BridgeAPI
    private let assetAccountRepository: ERC20AssetAccountRepository<Token>
    private let ethereumAssetAccountRepository: EthereumAssetAccountRepository
    private let feeService: AnyCryptoFeeService<EthereumTransactionFee>

    init(with bridge: ERC20BridgeAPI = resolve(),
         assetAccountRepository: ERC20AssetAccountRepository<Token> = resolve(),
         ethereumAssetAccountRepository: EthereumAssetAccountRepository = resolve(),
         feeService: AnyCryptoFeeService<EthereumTransactionFee> = resolve()) {
        self.bridge = bridge
        self.assetAccountRepository = assetAccountRepository
        self.ethereumAssetAccountRepository = ethereumAssetAccountRepository
        self.feeService = feeService
    }
    
    public func transfer(to: EthereumKit.EthereumAddress, amount cryptoValue: ERC20TokenValue<Token>) -> Single<EthereumTransactionCandidate> {
        buildTransactionCandidate(to: to, amount: cryptoValue, fee: nil)
    }
    
    public func transfer(
        to: EthereumKit.EthereumAddress,
        amount cryptoValue: ERC20TokenValue<Token>,
        fee: EthereumTransactionFee
        ) -> Single<EthereumTransactionCandidate> {
        buildTransactionCandidate(to: to, amount: cryptoValue, fee: fee)
    }
    
    public func transfer(proposal: ERC20TransactionProposal<Token>, to address: EthereumKit.EthereumAddress) -> Single<EthereumTransactionCandidate> {
        guard address.isValid else { return Single.error(ERC20ServiceError.invalidEthereumAddress) }
        guard proposal.aboveMinimumSpendable else { return Single.error(ERC20ValidationError.cryptoValueBelowMinimumSpendable) }
        return buildTransactionCandidate(to: address, amount: proposal.value, fee: nil)
    }
    
    private func buildTransactionCandidate(
        to: EthereumKit.EthereumAddress,
        amount cryptoValue: ERC20TokenValue<Token>,
        fee: EthereumTransactionFee? = nil
    ) -> Single<EthereumTransactionCandidate> {
        let tokenAmount = BigUInt(cryptoValue.amount)
        return handlePendingTransaction
            .flatMap(weak: self) { (self, _) -> Single<(EthereumTransactionFee, ERC20AssetAccountDetails, EthereumAssetAccountDetails)> in
                Single.zip(
                    self.feesFor(feeValue: fee),
                    self.tokenAssetAccountDetails,
                    self.ethereumAssetAccountDetails
                )
            }
            .flatMap(weak: self) { (self, tuple) -> Single<ValidatedInputs> in
                let (fee, tokenAccount, ethereumAccount) = tuple
                return self.validateTokenAndBalanceCoverage(
                    for: ValidationInputs(
                        value: cryptoValue,
                        fee: fee,
                        tokenAccountDetails: tokenAccount,
                        ethereumAccountDetails: ethereumAccount
                    )
                )
            }
            .flatMap(weak: self) { (self, validatedInputs) -> Single<(EthereumTransactionFee, web3swift.EthereumTransaction)> in
                let fee = validatedInputs.fee
                return self.transferTransaction(to: to, amount: tokenAmount)
                    .flatMap(weak: self) { (self, transaction) -> Single<(EthereumTransactionFee, web3swift.EthereumTransaction)> in
                        Single.just((fee, transaction))
                    }
            }
            .flatMap(weak: self) { (self, tuple) -> Single<EthereumTransactionCandidate> in
                let (fee, transaction) = tuple
                
                let transactionCandidate = EthereumTransactionCandidate(
                    to: EthereumAddress(stringLiteral: transaction.to.address),
                    gasPrice: BigUInt(fee.priority.amount),
                    gasLimit: BigUInt(fee.gasLimitContract),
                    value: BigUInt(0),
                    data: transaction.data
                )
                return Single.just(transactionCandidate)
            }
    }
    
    // MARK: ERC20TransactionEvaluationAPI
    
    public func evaluate(amount cryptoValue: ERC20TokenValue<Token>) -> Single<ERC20TransactionEvaluationResult<Token>> {
        buildProposal(with: cryptoValue).catchError({ (error) -> Single<ERC20TransactionEvaluationResult<Token>> in
            guard let validation = error as? ERC20ValidationError else {
                throw error
            }
            return Single.just(.invalid(validation))
        })
    }
    
    public func evaluate(amount cryptoValue: ERC20TokenValue<Token>, fee: EthereumTransactionFee) -> Single<ERC20TransactionEvaluationResult<Token>> {
        buildProposal(with: cryptoValue, fee: fee)
            .catchError { (error) -> Single<ERC20TransactionEvaluationResult<Token>> in
                guard let validation = error as? ERC20ValidationError else {
                    throw error
                }
                return Single.just(.invalid(validation))
        }
    }
    
    private func buildProposal(
        with cryptoValue: ERC20TokenValue<Token>,
        fee: EthereumTransactionFee? = nil)
        -> Single<ERC20TransactionEvaluationResult<Token>> {
        handlePendingTransaction
            .flatMap(weak: self) { (self, _) -> Single<(EthereumTransactionFee, ERC20AssetAccountDetails, EthereumAssetAccountDetails)> in
                Single.zip(
                    self.feesFor(feeValue: fee),
                    self.tokenAssetAccountDetails,
                    self.ethereumAssetAccountDetails
                )
            }
            .flatMap(weak: self) { (self, tuple) -> Single<ERC20Service<Token>.ValidatedInputs> in
                let (fee, tokenAccount, ethereumAccount) = tuple
                return self.validateTokenAndBalanceCoverage(
                    for: ERC20Service<Token>.ValidationInputs(
                        value: cryptoValue,
                        fee: fee,
                        tokenAccountDetails: tokenAccount,
                        ethereumAccountDetails: ethereumAccount
                    )
                )
            }
            .flatMap(weak: self) { (self, validatedInputs) -> Single<ERC20TransactionEvaluationResult<Token>> in
                let (fee, ethereumAccount) = (validatedInputs.fee, validatedInputs.ethereumAccountDetails)
                let transactionProposal = ERC20TransactionProposal(
                    from: EthereumKit.EthereumAddress(stringLiteral: ethereumAccount.account.accountAddress),
                    gasPrice: BigUInt(fee.priority.amount),
                    gasLimit: BigUInt(fee.gasLimitContract),
                    value: cryptoValue
                )
                return Single.just(.valid(transactionProposal))
            }
    }
    
    private func transferTransaction(to: EthereumKit.EthereumAddress, amount: BigUInt) -> Single<web3swift.EthereumTransaction> {
        let transaction: web3swift.EthereumTransaction
        do {
            let contractAddress: web3swift.Address = web3swift.Address(
                Token.contractAddress.publicKey
            )
            let contract = try ContractV2(Web3Utils.erc20ABI, at: contractAddress)
            let method: ERC20ContractMethod = .transfer
            let options = Web3Options()
            let toAddress: web3swift.Address = web3swift.Address(to.publicKey)
            let parameters: [Any] = [ toAddress, amount ]
            transaction = try contract.method(
                method.rawValue,
                parameters: parameters,
                options: options
            )
        } catch {
            return Single.error(error)
        }
        return Single.just(transaction)
    }
    
    private func feesFor(feeValue: EthereumTransactionFee?) -> Single<EthereumTransactionFee> {
        guard let fee = feeValue else { return feeService.fees }
        return Single.just(fee)
    }
    
    private func validateTokenAndBalanceCoverage(for inputs: ValidationInputs) -> Single<ValidatedInputs> {
        let (value, fee, tokenAccountDetails, ethereumAccountDetails) =
            (inputs.value, inputs.fee, inputs.tokenAccountDetails, inputs.ethereumAccountDetails)
        
        let tokenAmount = BigUInt(value.amount)
        let gasPrice = BigUInt(fee.priority.amount)
        let gasLimitContract = BigUInt(fee.gasLimitContract)
        let tokenBalance = BigUInt(tokenAccountDetails.balance.amount)
        let ethereumBalance = BigUInt(ethereumAccountDetails.balance.amount)
        let ethereumTransactionFee = gasPrice * gasLimitContract
        
        guard ethereumTransactionFee < ethereumBalance else {
            return Single.error(ERC20ValidationError.insufficientEthereumBalance)
        }
        
        guard tokenAmount <= tokenBalance else {
            return Single.error(ERC20ValidationError.insufficientTokenBalance)
        }
        
        return Single.just(
            ValidatedInputs(
                value: value,
                fee: fee,
                tokenAccountDetails: tokenAccountDetails,
                ethereumAccountDetails: ethereumAccountDetails
            )
        )
    }
}

extension ERC20Service: ERC20WalletAPI {
    public var tokenAccount: Single<ERC20TokenAccount?> {
        bridge.tokenAccount(for: Token.metadataKey)
    }
}

extension ERC20Service: ERC20TransactionMemoAPI {
    public func memo(for transactionHash: String) -> Single<String?> {
        bridge.memo(
            for: transactionHash,
            tokenKey: Token.metadataKey
        )
    }
    
    public func save(transactionMemo: String, for transactionHash: String) -> Single<Void> {
        bridge.save(
            transactionMemo: transactionMemo,
            for: transactionHash,
            tokenKey: Token.metadataKey
        )
    }
}

extension ERC20Service: ERC20ServiceAPI {}
