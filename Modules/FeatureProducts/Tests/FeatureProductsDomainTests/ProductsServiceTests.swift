@testable import FeatureProductsDomain
import Mockingbird
import NabuNetworkError
import TestKit
import ToolKit
import XCTest

final class ProductsServiceTests: XCTestCase {

    private var service: ProductsService!
    private var mockRepository: ProductsRepositoryAPIMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockRepository = mock(ProductsRepositoryAPI.self)
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
        given(mockRepository.fetchProducts()).willReturn(.failure(error))
        given(mockRepository.streamProducts()).willReturn(.just(.failure(error)))
    }

    private func stubRepository(with products: [Product]) throws {
        given(mockRepository.fetchProducts()).willReturn(.just(products))
        given(mockRepository.streamProducts()).willReturn(.just(.success(products)))
    }

    private func stubRepositoryWithDefaultProducts() throws -> [Product] {
        let expectedProducts = [
            Product(
                id: .swap,
                maxOrdersCap: 1,
                canPlaceOrder: false,
                suggestedUpgrade: Product.SuggestedUpgrade(requiredTier: 2)
            ),
            Product(
                id: .buy,
                maxOrdersCap: 1,
                canPlaceOrder: false,
                suggestedUpgrade: Product.SuggestedUpgrade(requiredTier: 2)
            )
        ]
        try stubRepository(with: expectedProducts)
        return expectedProducts
    }
}
