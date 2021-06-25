// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import SwiftUI
@testable import TransactionUIKit
import XCTest

final class TransactionsRouterTests: XCTestCase {

    private var router: TransactionsRouter!
    private var mockLegacyBuyFlowPresenter: MockLegacyBuyFlowPresenter!
    private var mockCryptoCurrencyService: MockCryptoCurrenciesService!
    private var mockFeatureFlagsService: InternalFeatureFlagServiceMock!
    private var mockKYCService: MockKYCSDDService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockCryptoCurrencyService = MockCryptoCurrenciesService()
        mockFeatureFlagsService = InternalFeatureFlagServiceMock()
        mockKYCService = MockKYCSDDService()
        mockLegacyBuyFlowPresenter = MockLegacyBuyFlowPresenter(
            cryptoCurrenciesService: mockCryptoCurrencyService,
            kycService: mockKYCService
        )
        router = TransactionsRouter(
            featureFlagsService: mockFeatureFlagsService,
            legacyBuyPresenter: mockLegacyBuyFlowPresenter
        )
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        router = nil
        mockKYCService = nil
        mockFeatureFlagsService = nil
        mockCryptoCurrencyService = nil
        mockLegacyBuyFlowPresenter = nil
    }

    func test_routesTo_legacyBuyFlow_featueFlagOff() throws {
        mockFeatureFlagsService.disable(.useTransactionsFlowToBuyCrypto)
        let mockViewController = MockViewController()
        let cancellable = router.presentTransactionFlow(to: .buy(.bitcoin), from: mockViewController)
            .sink { _ in
                // no-op
            }

        XCTAssertEqual(mockLegacyBuyFlowPresenter.recordedInvocations.presentBuyScreen, 1)
        cancellable.cancel()
    }

    func test_routesTo_legacyBuyFlow_featueFlagOn() throws {
        mockFeatureFlagsService.enable(.useTransactionsFlowToBuyCrypto)
        let mockViewController = MockViewController()
        let cancellable = router.presentTransactionFlow(to: .buy(.bitcoin), from: mockViewController)
            .sink { _ in
                // no-op
            }

        // TODO: IOS-4879 update this as concrete implementation gets built...
        let presentedViewController = mockViewController.recordedInvocations.presentViewController.first
        XCTAssertEqual(presentedViewController?.view.backgroundColor, .red)
        cancellable.cancel()
    }
}

final class MockLegacyBuyFlowPresenter: LegacyBuyFlowPresenter {

    struct RecordedInvocations {
        var presentBuyScreen: Int = 0
    }

    private(set) var recordedInvocations = RecordedInvocations()

    override func presentBuyScreen(
        from presenter: UIViewController,
        targetCurrency: CryptoCurrency,
        sourceCurrency: FiatCurrency,
        isSDDEligible: Bool = true
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        recordedInvocations.presentBuyScreen += 1
        return .empty()
    }
}
