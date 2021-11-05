// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureTransactionDomainMock
@testable import FeatureTransactionUI
@testable import FeatureTransactionUIMock
@testable import PlatformUIKitMock
import TestKit
@testable import ToolKitMock
import XCTest

final class TransactionsRouterTests: XCTestCase {

    private var router: TransactionsRouter!
    private var mockBuyFlowBuilder: MockBuyFlowBuilder!
    private var mockLegacyBuyFlowRouter: MockLegacyBuyFlowRouter!
    private var mockFeatureFlagsService: MockFeatureFlagsService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockFeatureFlagsService = MockFeatureFlagsService()
        mockLegacyBuyFlowRouter = MockLegacyBuyFlowRouter()
        mockBuyFlowBuilder = MockBuyFlowBuilder()
        router = TransactionsRouter(
            featureFlagsService: mockFeatureFlagsService,
            pendingOrdersService: MockPendingOrderDetailsService(),
            kycRouter: MockTransactionsKYCRouter(),
            alertViewPresenter: MockAlertViewPresenter(),
            topMostViewControllerProvider: MockTopMostViewControllerProvider(),
            loadingViewPresenter: MockLoadingViewPresenter(),
            legacyBuyRouter: mockLegacyBuyFlowRouter,
            buyFlowBuilder: mockBuyFlowBuilder
        )
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        router = nil
        mockFeatureFlagsService = nil
        mockLegacyBuyFlowRouter = nil
    }

    func test_routesTo_legacyBuyFlow_forCryptoAccount_featueFlagOff() throws {
        XCTAssertPublisherCompletion(mockFeatureFlagsService.disable(.local(.useTransactionsFlowToBuyCrypto)))
        let mockViewController = MockViewController()
        let cryptoAccount = ReceivePlaceholderCryptoAccount(asset: .coin(.bitcoin))
        let publisher = router.presentTransactionFlow(to: .buy(cryptoAccount), from: mockViewController)
        XCTAssertPublisherCompletion(publisher)
        let recordedInvocations = mockLegacyBuyFlowRouter.recordedInvocations
        XCTAssertEqual(recordedInvocations.presentBuyScreen, 1)
    }

    func test_routesTo_legacyBuyFlow_nilAccount_featueFlagOff() throws {
        XCTAssertPublisherCompletion(mockFeatureFlagsService.disable(.local(.useTransactionsFlowToBuyCrypto)))
        let mockViewController = MockViewController()
        let publisher = router.presentTransactionFlow(to: .buy(nil), from: mockViewController)
        XCTAssertPublisherCompletion(publisher)
        let recordedInvocations = mockLegacyBuyFlowRouter.recordedInvocations
        XCTAssertEqual(recordedInvocations.presentBuyFlowWithTargetCurrencySelectionIfNecessary, 1)
    }

    func test_routesTo_legacyBuyFlow_featueFlagOn_nilAccount() throws {
        XCTAssertPublisherCompletion(mockFeatureFlagsService.enable(.local(.useTransactionsFlowToBuyCrypto)))
        let mockViewController = MockViewController()
        let publisher = router.presentTransactionFlow(to: .buy(nil), from: mockViewController)
        XCTAssertPublisherCompletion(publisher)
        let mockRouter = mockBuyFlowBuilder.builtRouters.first
        let buyStartRequests = mockRouter?.recordedInvocations.start
        XCTAssertEqual(buyStartRequests?.count, 1)
        XCTAssertNil(buyStartRequests?.first?.cryptoAccount)
    }

    func test_routesTo_legacyBuyFlow_featueFlagOn_nonNilAccount() throws {
        XCTAssertPublisherCompletion(mockFeatureFlagsService.enable(.local(.useTransactionsFlowToBuyCrypto)))
        let mockViewController = MockViewController()
        let cryptoAccount = ReceivePlaceholderCryptoAccount(asset: .coin(.bitcoin))
        let publisher = router.presentTransactionFlow(to: .buy(cryptoAccount), from: mockViewController)
        XCTAssertPublisherCompletion(publisher)
        let mockRouter = mockBuyFlowBuilder.builtRouters.first
        let buyStartRequests = mockRouter?.recordedInvocations.start
        XCTAssertEqual(buyStartRequests?.count, 1)
        XCTAssertEqual(buyStartRequests?.first?.cryptoAccount?.asset, .coin(.bitcoin))
    }
}
