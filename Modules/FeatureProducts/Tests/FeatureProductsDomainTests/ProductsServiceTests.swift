@testable import FeatureProductsDomain
import Mockingbird
import NabuNetworkError
import TestKit
import ToolKit
import XCTest

final class ProductsServiceTests: XCTestCase {

    private var service: ProductsService!
    private var mockRepository: ProductsRepositoryMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockRepository = ProductsRepositoryMock()
        service = ProductsService(repository: mockRepository)
    }

    override func tearDownWithError() throws {
        service = nil
        mockRepository = nil
        try super.tearDownWithError()
    }

    func test_fetch_returnsRepositoryError() throws {
        let error = NabuNetworkError.communicatorError(.serverError(.badResponse))
        try stubRepository(with: error)
        let publisher = service.fetchProducts()
        XCTAssertPublisherError(publisher, .network(error))
    }

    func test_fetch_returnsRepositoryValues() throws {
        let expectedProducts = try stubRepositoryWithDefaultProducts()
        let publisher = service.fetchProducts()
        XCTAssertPublisherValues(publisher, expectedProducts)
    }

    func test_stream_returnsRepositoryError() throws {
        let error = NabuNetworkError.communicatorError(.serverError(.badResponse))
        try stubRepository(with: error)
        let publisher = service.fetchProducts()
        XCTAssertPublisherError(publisher, .network(error))
    }

    func test_stream_publishesProducts() throws {
        let expectedProducts = try stubRepositoryWithDefaultProducts()
        let publisher = service.streamProducts()
        XCTAssertPublisherValues(publisher, .success(expectedProducts))
    }

    // MARK: - Private

    private func stubRepository(with error: NabuNetworkError) throws {
        mockRepository.stubbedResponses.fetchProducts = .failure(error)
        mockRepository.stubbedResponses.streamProducts = .just(.failure(error))
    }

    private func stubRepository(with products: [ProductValue]) throws {
        mockRepository.stubbedResponses.fetchProducts = .just(products)
        mockRepository.stubbedResponses.streamProducts = .just(.success(products))
    }

    private func stubRepositoryWithDefaultProducts() throws -> [ProductValue] {
        let expectedProducts = [
            ProductValue.trading(
                TradingProduct(
                    id: .swap,
                    enabled: true,
                    maxOrdersCap: 1,
                    maxOrdersLeft: 0,
                    canPlaceOrder: false,
                    suggestedUpgrade: ProductSuggestedUpgrade(requiredTier: 2)
                )
            ),
            ProductValue.trading(
                TradingProduct(
                    id: .buy,
                    enabled: true,
                    maxOrdersCap: nil,
                    maxOrdersLeft: nil,
                    canPlaceOrder: true,
                    suggestedUpgrade: nil
                )
            ),
            ProductValue.custodialWallet(
                CustodialWalletProduct(
                    id: .custodialWallet,
                    enabled: true,
                    canDepositFiat: false,
                    canDepositCrypto: true,
                    canWithdrawCrypto: true,
                    canWithdrawFiat: true,
                    suggestedUpgrade: nil
                )
            )
        ]
        try stubRepository(with: expectedProducts)
        return expectedProducts
    }
}
