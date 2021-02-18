//
//  ERC20ServiceTests.swift
//  ERC20KitTests
//
//  Created by Jack on 19/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
@testable import ERC20Kit
@testable import EthereumKit
@testable import PlatformKit
import RxSwift
import RxTest
import XCTest
import ToolKit

enum ERC20ServiceMockError: Error {
    case mockError
}

class ERC20ServiceTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    var erc20Bridge: ERC20BridgeMock!
    
    var ethereumAPIAccountClient: EthereumAPIClientMock!
    var accountAPIClient: ERC20AccountAPIClientMock!
    var ethereumWalletBridge: ERC20EthereumWalletBridgeMock!
    var assetAccountDetailsService: ERC20AssetAccountDetailsService<PaxToken>!
    var assetAccountRepository: ERC20AssetAccountRepository<PaxToken>!
    
    var ethereumAssetAccountDetailsService: EthereumAssetAccountDetailsService!
    var ethereumAssetAccountRepository: EthereumAssetAccountRepository!
    
    var feeService: AnyCryptoFeeService<EthereumTransactionFee>!
    var subject: ERC20Service<PaxToken>!
    
    override func setUp() {
        super.setUp()
        
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        
        erc20Bridge = ERC20BridgeMock()
        
        ethereumAPIAccountClient = EthereumAPIClientMock()
        accountAPIClient = ERC20AccountAPIClientMock()
        ethereumWalletBridge = ERC20EthereumWalletBridgeMock()

        let balanceService = ERC20BalanceService<PaxToken>(with: ethereumWalletBridge, accountClient: accountAPIClient)

        assetAccountDetailsService = ERC20AssetAccountDetailsService(
            with: ethereumWalletBridge,
            service: balanceService
        )

        assetAccountRepository = ERC20AssetAccountRepository(
            service: AnyAssetAccountDetailsAPI(service: assetAccountDetailsService)
        )
        
        ethereumAssetAccountDetailsService = EthereumAssetAccountDetailsService(
            with: ethereumWalletBridge,
            client: ethereumAPIAccountClient
        )
        ethereumAssetAccountRepository = EthereumAssetAccountRepository(
            service: ethereumAssetAccountDetailsService
        )
        feeService = AnyCryptoFeeService(
            service: CryptoFeeServiceMock<EthereumTransactionFee>(underlyingFees: .default)
        )
        subject = ERC20Service(
            with: erc20Bridge,
            assetAccountRepository: assetAccountRepository,
            ethereumAssetAccountRepository: ethereumAssetAccountRepository,
            feeService: feeService
        )
    }
    
    override func tearDown() {
        scheduler = nil
        disposeBag = nil
        erc20Bridge = nil
        ethereumAPIAccountClient = nil
        accountAPIClient = nil
        ethereumWalletBridge = nil
        assetAccountDetailsService = nil
        assetAccountRepository = nil
        ethereumAssetAccountDetailsService = nil
        ethereumAssetAccountRepository = nil
        feeService = nil
        subject = nil
        
        super.tearDown()
    }
    
    func test_build_transfer() throws {
        // Arrange
        let expectedTransaction = EthereumTransactionCandidate(
            to: "0x3535353535353535353535353535353535353535",
            gasPrice: MockEthereumWalletTestData.Transaction.gasPrice,
            gasLimit: MockEthereumWalletTestData.Transaction.gasLimitContract,
            value: BigUInt("1", decimals: CryptoCurrency.ethereum.maxDecimalPlaces)!,
            data: nil,
            transferType: .erc20Transfer(contract: PaxToken.contractAddress.ethereumAddress)
        )
        let cryptoValue = CryptoValue.ether(major: "10.0")!
        ethereumAPIAccountClient.balanceDetailsValue = Single.just(.init(balance: cryptoValue.amount.description, nonce: 1))
        
        let to = EthereumAddress(stringLiteral: MockEthereumWalletTestData.Transaction.to)
        let amountCrypto = CryptoValue.pax(major: "1.0")!
        let amount = try ERC20TokenValue<PaxToken>(crypto: amountCrypto)
        let transferObservable = subject.transfer(to: to, amount: amount).asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionCandidate> = scheduler
            .start { transferObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionCandidate>>] = Recorded.events(
            .next(
                200,
                expectedTransaction
            ),
            .completed(200)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_build_transfer_amount_over_token_balance() throws {
        // Arrange
        
        let ethBalance = CryptoValue.ether(major: "10.0")!
        ethereumAPIAccountClient.balanceDetailsValue = Single.just(.init(balance: ethBalance.amount.description, nonce: 1))

        let accountResponse = ERC20AccountSummaryResponse<PaxToken>(
            balance: CryptoValue.pax(major: "0.1")!.amount.string(unitDecimals: 0)
        )
        accountAPIClient.fetchAccountSummaryResponse = Single<ERC20AccountSummaryResponse<PaxToken>>.just(accountResponse)

        let cryptoValue = CryptoValue.pax(major: "1.0")!
        let amount = try ERC20TokenValue<PaxToken>(crypto: cryptoValue)
        let to = EthereumAddress(stringLiteral: MockEthereumWalletTestData.Transaction.to)
        
        let transferObservable = subject.transfer(to: to, amount: amount).asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionCandidate> = scheduler
            .start { transferObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionCandidate>>] = Recorded.events(
            .error(200, ERC20ValidationError.insufficientTokenBalance)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_build_transfer_ethereum_fees_over_ethereum_balance() throws {
        // Arrange
        let cryptoValue = CryptoValue.pax(major: "1.00")!
        let amount = try ERC20TokenValue<PaxToken>(crypto: cryptoValue)
        let to = EthereumAddress(stringLiteral: MockEthereumWalletTestData.Transaction.to)

        let limits = TransactionFeeLimits(
            min: 100,
            max: 1_100
        )
        let fee = EthereumTransactionFee(
            limits: limits,
            regular: 1_000,
            priority: 1_000,
            gasLimit: Int(MockEthereumWalletTestData.Transaction.gasLimit),
            gasLimitContract: Int(MockEthereumWalletTestData.Transaction.gasLimitContract)
        )
        feeService = AnyCryptoFeeService(
            service: CryptoFeeServiceMock<EthereumTransactionFee>(underlyingFees: fee)
        )
        
        ethereumAPIAccountClient.balanceDetailsValue = .just(BalanceDetailsResponse(balance: "0.01", nonce: 1))
         
        let transferObservable = subject.transfer(to: to, amount: amount).asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionCandidate> = scheduler
            .start { transferObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionCandidate>>] = Recorded.events(
            .error(200, ERC20ValidationError.insufficientEthereumBalance)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_failed_to_fetch_ether_balance() throws {
        // Arrange
        let cryptoValue = CryptoValue.pax(major: "1.00")!
        let amount = try ERC20TokenValue<PaxToken>(crypto: cryptoValue)
        let to = EthereumAddress(stringLiteral: MockEthereumWalletTestData.Transaction.to)

        ethereumAPIAccountClient.balanceDetailsValue = Single.error(ERC20ServiceMockError.mockError)

        let transferObservable = subject.transfer(to: to, amount: amount).asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionCandidate> = scheduler
            .start { transferObservable }

        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionCandidate>>] = Recorded.events(
            .error(200, ERC20ServiceMockError.mockError)
        )

        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_failed_to_fetch_token_balance() throws {
        // Arrange
        let cryptoValue = CryptoValue.pax(major: "1.00")!
        let amount = try ERC20TokenValue<PaxToken>(crypto: cryptoValue)
        let to = EthereumAddress(stringLiteral: MockEthereumWalletTestData.Transaction.to)
        
        accountAPIClient.fetchAccountSummaryResponse = Single.error(ERC20ServiceMockError.mockError)
        
        let transferObservable = subject.transfer(to: to, amount: amount).asObservable()
        
        // Act
        let result: TestableObserver<EthereumTransactionCandidate> = scheduler
            .start { transferObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<EthereumTransactionCandidate>>] = Recorded.events(
            .error(200, ERC20ServiceMockError.mockError)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
    }
    
    func test_get_memo_for_transaction_hash() throws {
        // Arrange
        let expectedMemo = "expectedMemo"
        let transactionHash = "transactionHash"
        let tokenKey = PaxToken.metadataKey
        
        erc20Bridge.memoForTransactionHashValue = Single.just(expectedMemo)
        
        let memoObservable = subject.memo(for: transactionHash).asObservable()
        
        // Act
        let result: TestableObserver<String?> = scheduler
            .start { memoObservable }
        
        // Assert
        let expectedEvents: [Recorded<Event<String?>>] = Recorded.events(
            .next(
                200,
                expectedMemo
            ),
            .completed(200)
        )
        
        XCTAssertEqual(result.events, expectedEvents)
        XCTAssertEqual(erc20Bridge.lastTransactionHashFetched, transactionHash)
        XCTAssertEqual(erc20Bridge.lastTokenKeyFetched, tokenKey)
    }
    
    func test_save_memo_for_transaction_hash() throws {
        // Arrange
        let transactionHash = "transactionHash"
        let transactionMemo = "transactionMemo"
        let tokenKey = PaxToken.metadataKey
        
        let saveMemoObservable = subject
            .save(transactionMemo: transactionMemo, for: transactionHash)
            .asObservable()
        
        // Act
        let result: TestableObserver<Void> = scheduler
            .start { saveMemoObservable }
        
        // Assert
        guard result.events.count == 2, result.events.first?.value != nil, result.events.last!.value.isCompleted else {
            XCTFail("Saving should complete successfully")
            return
        }
        
        XCTAssertEqual(erc20Bridge.lastTransactionMemoSaved, transactionMemo)
        XCTAssertEqual(erc20Bridge.lastTransactionHashSaved, transactionHash)
        XCTAssertEqual(erc20Bridge.lastTokenKeySaved, tokenKey)
    }
}
