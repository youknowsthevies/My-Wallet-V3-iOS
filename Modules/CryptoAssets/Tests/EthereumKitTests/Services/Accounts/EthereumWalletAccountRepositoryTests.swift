// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumKit
@testable import EthereumKitMock
import PlatformKit
@testable import PlatformKitMock
import RxSwift
import RxTest
import XCTest

class EthereumWalletAccountRepositoryTests: XCTestCase {

    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    var accountBridge: EthereumWalletAccountBridgeMock!
    var ethereumDeriver: EthereumKeyPairDeriverMock!
    var deriver: AnyEthereumKeyPairDeriver!
    var subject: EthereumWalletAccountRepository!

    override func setUp() {
        super.setUp()

        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()

        accountBridge = EthereumWalletAccountBridgeMock()
        ethereumDeriver = EthereumKeyPairDeriverMock()
        deriver = AnyEthereumKeyPairDeriver(deriver: ethereumDeriver)

        subject = EthereumWalletAccountRepository(
            mnemonicAccess: MnemonicAccessMock(),
            accountBridge: accountBridge,
            deriver: deriver
        )
    }

    override func tearDown() {
        scheduler = nil
        disposeBag = nil

        accountBridge = nil
        ethereumDeriver = nil
        deriver = nil
        subject = nil

        super.tearDown()
    }

    func test_load_key_pair() {
        // Arrange
        let expectedKeyPair = MockEthereumWalletTestData.keyPair

        let sendObservable: Observable<EthereumKeyPair> = subject.keyPair
            .asObservable()

        // Act
        let result: TestableObserver<EthereumKeyPair> = scheduler
            .start { sendObservable }

        // Assert
        let expectedEvents: [Recorded<Event<EthereumKeyPair>>] = Recorded.events(
            .next(
                200,
                expectedKeyPair
            ),
            .completed(200)
        )

        XCTAssertEqual(result.events, expectedEvents)
    }
}
