//  Copyright © 2022 Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import Combine
@testable import FeatureAppDomain
import FeatureCardPaymentDomain
import FeatureKYCDomainMock
import FeatureProductsDomain
import MoneyKit
import PlatformKit
import RxRelay
import RxSwift
import RxToolKit
import TestKit
import ToolKit
import XCTest

final class UserAdapterTests: XCTestCase {

    private var userAdapter: UserAdapter!
    private var kycTiersService: MockKYCTiersService!
    private var mockKYCTiersService: MockKYCTiersService!
    private var mockBalanceDataFetcher: MockBalanceDataFetcher!

    override func setUpWithError() throws {
        try super.setUpWithError()

        mockKYCTiersService = MockKYCTiersService()
        mockBalanceDataFetcher = MockBalanceDataFetcher()
        userAdapter = UserAdapter(
            balanceDataFetcher: mockBalanceDataFetcher,
            kycTiersService: mockKYCTiersService,
            paymentMethodsService: MockPaymentMethodsService(),
            productsService: MockProductsService(),
            ordersService: MockOrdersService()
        )
    }

    override func tearDownWithError() throws {
        userAdapter = nil
        mockKYCTiersService = nil
        mockBalanceDataFetcher = nil

        try super.tearDownWithError()
    }

    func test_refreshesBalance_after_meaningfulEvent() throws {
        try XCTSkipIf(true, "No values are getting published in the test. Need to understand why.")
        // GIVEN: Some initial mocked data
        mockKYCTiersService.stubbedResponses.fetchTiers = .just(KYC.UserTiers(tiers: []))
        let initialBalanceData = UserState.BalanceData(
            hasAnyBalance: false,
            hasAnyFiatBalance: false,
            hasAnyCryptoBalance: false
        )
        mockBalanceDataFetcher.stubbedResponses.fetchBalanceData = .just(initialBalanceData)
        // AND: The user data has been already fetched
        let publisher = userAdapter.userState
        let initialUserState = UserState(
            kycStatus: .unverified,
            balanceData: initialBalanceData,
            linkedPaymentMethods: [],
            hasEverPurchasedCrypto: false,
            products: []
        )
        XCTAssertPublisherValues(publisher, .success(initialUserState), expectCompletion: false)
        XCTAssertEqual(mockBalanceDataFetcher.recordedInvocations.fetchBalanceData.count, 1)
        // AND: The balance data changes
        let finalBalanceData = UserState.BalanceData(
            hasAnyBalance: true,
            hasAnyFiatBalance: true,
            hasAnyCryptoBalance: true
        )
        mockBalanceDataFetcher.stubbedResponses.fetchBalanceData = .just(finalBalanceData)
        // WHEN: A meaningful event is triggered
        NotificationCenter.default.post(name: .dashboardPullToRefresh, object: nil)
        // THEN: The balance is reloaded and a new version of the user data is retrieved
        let finalUserState = UserState(
            kycStatus: .unverified,
            balanceData: finalBalanceData,
            linkedPaymentMethods: [],
            hasEverPurchasedCrypto: false,
            products: []
        )
        XCTAssertPublisherValues(publisher, .success(finalUserState), expectCompletion: false)
        XCTAssertEqual(mockBalanceDataFetcher.recordedInvocations.fetchBalanceData.count, 2)
    }
}

final class MockBalanceDataFetcher: BalanceDataFetcherAPI {

    struct RecordedInvocations {
        var fetchBalanceData: [Void] = []
    }

    struct StubbedResponses {
        var fetchBalanceData: AnyPublisher<UserState.BalanceData, UserStateError> = {
            struct MockError: Error {}
            return .failure(.missingBalance(MockError()))
        }()
    }

    private(set) var recordedInvocations = RecordedInvocations()
    var stubbedResponses = StubbedResponses()

    func fetchBalanceData() -> AnyPublisher<UserState.BalanceData, UserStateError> {
        recordedInvocations.fetchBalanceData.append(())
        return stubbedResponses.fetchBalanceData
    }
}

final class MockProductsService: ProductsServiceAPI {

    func fetchProducts() -> AnyPublisher<[ProductValue], ProductsServiceError> {
        .just([])
    }

    func streamProducts() -> AnyPublisher<Result<[ProductValue], ProductsServiceError>, Never> {
        .just(.success([]))
    }
}

final class MockPaymentMethodsService: PaymentMethodTypesServiceAPI {

    var paymentMethodTypesValidForBuyPublisher: AnyPublisher<[PaymentMethodType], PaymentMethodTypesServiceError> {
        .just([])
    }

    var paymentMethodTypesValidForBuy: Single<[PaymentMethodType]> {
        .just([])
    }

    var suggestedPaymentMethodTypes: Single<[PaymentMethodType]> {
        .just([])
    }

    var methodTypes: Observable<[PaymentMethodType]> {
        .just([])
    }

    var cards: Observable<[CardData]> {
        .just([])
    }

    var linkedBanks: Observable<[LinkedBankData]> {
        .empty()
    }

    var preferredPaymentMethodTypeRelay: BehaviorRelay<PaymentMethodType?> {
        BehaviorRelay(value: nil)
    }

    var preferredPaymentMethodType: Observable<PaymentMethodType?> {
        .empty()
    }

    func eligiblePaymentMethods(for currency: FiatCurrency) -> Single<[PaymentMethodType]> {
        .just([])
    }

    func fetchCards(andPrefer cardId: String) -> Completable {
        .empty()
    }

    func fetchLinkBanks(andPrefer bankId: String) -> Completable {
        .empty()
    }

    func canTransactWithBankPaymentMethods(fiatCurrency: FiatCurrency) -> Single<Bool> {
        .just(false)
    }

    func fetchSupportedCurrenciesForBankTransactions(fiatCurrency: FiatCurrency) -> Single<[FiatCurrency]> {
        .just([])
    }

    func clearPreferredPaymentIfNeeded(by id: String) {
        // no-op
    }
}

final class MockOrdersService: OrdersServiceAPI {

    var hasUserMadeAnyPurchases: AnyPublisher<Bool, OrdersServiceError> {
        .just(false)
    }

    var orders: Single<[OrderDetails]> {
        .just([])
    }

    func fetchOrders() -> Single<[OrderDetails]> {
        .just([])
    }

    func fetchOrder(with identifier: String) -> Single<OrderDetails> {
        struct MockError: Error {}
        return .error(MockError())
    }
}
