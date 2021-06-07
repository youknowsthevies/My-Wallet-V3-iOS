// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import ERC20Kit
import EthereumKit
import PlatformKit
import PlatformUIKit
import RxSwift
import RxTest
import XCTest

// swiftlint:disable all
class EthereumWalletTests: XCTestCase {

    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    var subject: EthereumWallet!
    var legacyWalletMock: MockLegacyEthereumWallet!
    var reactiveWallet: ReactiveWalletAPI!

    override func setUp() {
        super.setUp()

        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        reactiveWallet = ReactiveWalletMock()
        legacyWalletMock = MockLegacyEthereumWallet()
        // Hack to make things compile
        subject = EthereumWallet(
            schedulerType: scheduler,
            secondPasswordPrompter: SecondPasswordPromptableMock(),
            wallet: legacyWalletMock
        )
        subject.reactiveWallet = reactiveWallet
    }

    override func tearDown() {
        legacyWalletMock = nil
        subject = nil
        super.tearDown()
    }

    func test_wallet_name() {
        // Arrange
        let expectedName = "My ETH Wallet"
        let nameObservable: Observable<String> = subject
            .name
            .asObservable()

        // Act
        let result: TestableObserver<String> = scheduler
            .start { nameObservable }

        // Assert
        let expectedEvents: [Recorded<Event<String>>] = Recorded.events(
            .next(
                200,
                expectedName
            ),
            .completed(200)
        )

        let expectedElement = expectedEvents[0].value.element
        XCTAssertEqual(expectedName, expectedElement)

        let resultElement = result.events[0].value.element
        XCTAssertEqual(resultElement, expectedElement)
    }

    func test_wallet_address() {
        // Arrange
        let expectedAddress = EthereumAddress(stringLiteral: "address")
        let addressObservable: Observable<EthereumAddress> = subject
            .address
            .asObservable()

        // Act
        let result: TestableObserver<EthereumAddress> = scheduler
            .start { addressObservable }

        // Assert
        let expectedEvents: [Recorded<Event<EthereumAddress>>] = Recorded.events(
            .next(
                200,
                expectedAddress
            ),
            .completed(200)
        )

        let expectedElement = expectedEvents[0].value.element
        XCTAssertEqual(expectedAddress, expectedElement)

        let resultElement = result.events[0].value.element
        XCTAssertEqual(resultElement, expectedElement)
    }

    func test_wallet_account() {
        // Arrange
        let expectedAccount = EthereumAssetAccount(
            walletIndex: 0,
            accountAddress: "0xE408d13921DbcD1CBcb69840e4DA465Ba07B7e5e",
            name: "My ETH Wallet"
        )

        let accountObservable: Observable<EthereumAssetAccount> = subject
            .account
            .asObservable()

        // Act
        let result: TestableObserver<EthereumAssetAccount> = scheduler
            .start { accountObservable }

        // Assert
        let expectedEvents: [Recorded<Event<EthereumAssetAccount>>] = Recorded.events(
            .next(
                200,
                expectedAccount
            ),
            .completed(200)
        )

        XCTAssertEqual(result.events, expectedEvents)
    }

    func test_wallet_not_initialised() {
        // Arrange
        legacyWalletMock.ethereumAccountsCompletion = .failure(
            MockLegacyEthereumWallet.MockLegacyEthereumWalletError.notInitialized
        )

        let walletObservable: Observable<EthereumAssetAccount> = subject
            .account
            .asObservable()

        // Act
        let result: TestableObserver<EthereumAssetAccount> = scheduler
            .start { walletObservable }

        // Assert
        let expectedEvents: [Recorded<Event<EthereumAssetAccount>>] = Recorded.events(
            .error(200, EthereumWallet.EthereumWalletError.ethereumAccountsFailed)
        )

        XCTAssertEqual(result.events, expectedEvents)
    }
}
