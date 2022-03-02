@testable import FeatureProductsData
import FeatureProductsDomain
import Mockingbird
import NabuNetworkError
import TestKit
import ToolKit
import XCTest

final class ProductsRepositoryTests: XCTestCase {

    private var repository: ProductsRepository!
    private var mockClient: ProductsClientAPIMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockClient = mock(ProductsClientAPI.self)
        repository = ProductsRepository(client: mockClient)
    }

    override func tearDownWithError() throws {
        repository = nil
        mockClient = nil
        try super.tearDownWithError()
    }

    func test_returnsError() throws {
        let error = NabuNetworkError.communicatorError(.serverError(.badResponse))
        try stubClientProductsDataResponse(with: error)
        let publisher = repository.fetchProducts()
        XCTAssertPublisherError(publisher, error)
    }

    func test_returnsProducts_allValid() throws {
        let expectedProducts = try stubClientWithDefaultProducts()
        let publisher = repository.fetchProducts()
        XCTAssertPublisherValues(publisher, expectedProducts)
    }

    func test_returnsProducts_with_unkown_identifier() throws {
        // GIVEN: The client returns a list of products containing some products we don't understand
        try stubClientProductsDataResponse(usingFileNamed: "stub_products_unknown")
        // WHEN: The repository fetches products
        let publisher = repository.fetchProducts()
        // THEN: The unknown products are filtered out and the request still succeeds returning only the known ones
        let expectedProducts = [
            Product(
                id: .swap,
                maxOrdersCap: 1,
                canPlaceOrder: false,
                suggestedUpgrade: Product.SuggestedUpgrade(requiredTier: 2)
            )
        ]
        XCTAssertPublisherValues(publisher, expectedProducts)
    }

    func test_cache_validCache() throws {
        // GIVEN: A first request is fired, thus caching the response
        let expectedProducts = try stubClientWithDefaultProducts()
        let firstRequestPublisher = repository.fetchProducts()
        XCTAssertPublisherValues(firstRequestPublisher, expectedProducts)
        // WHEN: A second request is fired
        let secondRequestPublisher = repository.fetchProducts()
        XCTAssertPublisherValues(secondRequestPublisher, expectedProducts)
        // THEN: The repository has used the cache to serve the response
        verify(mockClient.fetchProductsData()).wasCalled(exactly(once))
    }

    func test_cache_invalidatesCacheOn_transactionNotification() throws {
        // GIVEN: A first request is fired, thus caching the response
        let expectedProducts = try stubClientWithDefaultProducts()
        let firstRequestPublisher = repository.fetchProducts()
        XCTAssertPublisherValues(firstRequestPublisher, expectedProducts)
        // WHEN: The cache should be invalidated
        NotificationCenter.default.post(name: .transaction, object: nil)
        // AND: A second request is fired
        let secondRequestPublisher = repository.fetchProducts()
        XCTAssertPublisherValues(secondRequestPublisher, expectedProducts)
        // THEN: The repository has NOT used the cache to serve the response
        verify(mockClient.fetchProductsData()).wasCalled(exactly(twice))
    }

    func test_cache_invalidatesCacheOn_kycStatusChangedNotification() throws {
        // GIVEN: A first request is fired, thus caching the response
        let expectedProducts = try stubClientWithDefaultProducts()
        let firstRequestPublisher = repository.fetchProducts()
        XCTAssertPublisherValues(firstRequestPublisher, expectedProducts)
        // WHEN: The cache should be invalidated
        NotificationCenter.default.post(name: .kycStatusChanged, object: nil)
        // AND: A second request is fired
        let secondRequestPublisher = repository.fetchProducts()
        XCTAssertPublisherValues(secondRequestPublisher, expectedProducts)
        // THEN: The repository has NOT used the cache to serve the response
        verify(mockClient.fetchProductsData()).wasCalled(exactly(twice))
    }

    func test_stream_publishesNewValues_whenCacheIsInvalidated() throws {
        // GIVEN: A stream is requested
        let expectedProducts = try stubClientWithDefaultProducts()
        let publisher = repository.streamProducts()
        XCTAssertPublisherValues(publisher, .success(expectedProducts), expectCompletion: false)
        // WHEN: The cache is invalidated
        NotificationCenter.default.post(name: .kycStatusChanged, object: nil)
        // AND: The data is refreashed
        XCTAssertPublisherValues(publisher, .success(expectedProducts), expectCompletion: false)
        verify(mockClient.fetchProductsData()).wasCalled(exactly(twice))
    }

    func test_stream_doesNotFailOnFailure() throws {
        // GIVEN: The stream returns an error
        let error = NabuNetworkError.communicatorError(.serverError(.badResponse))
        try stubClientProductsDataResponse(with: error)
        // WHEN: A stream is requested
        let publisher = repository.streamProducts()
        // THEN: The failure is returned
        XCTAssertPublisherValues(publisher, .failure(error), expectCompletion: false)
        // WHEN: The cache is invalidated
        NotificationCenter.default.post(name: .kycStatusChanged, object: nil)
        // AND: Valid data is available
        let expectedProducts = try stubClientWithDefaultProducts()
        // THEN: The data is refreashed
        XCTAssertPublisherValues(publisher, .success(expectedProducts), expectCompletion: false)
        verify(mockClient.fetchProductsData()).wasCalled(exactly(twice))
    }

    // MARK: - Helpers

    private func stubClientWithDefaultProducts() throws -> [Product] {
        // stub using local file
        try stubClientProductsDataResponse(usingFileNamed: "stub_products")
        // return expected products from parsing the file
        return [
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
    }

    private func stubClientProductsDataResponse(usingFileNamed fileName: String) throws {
        enum FixtureError: Error {
            case fileNotFound
        }

        guard let stubbedResponseURL = Bundle.module.url(forResource: fileName, withExtension: "json") else {
            throw FixtureError.fileNotFound
        }
        let stubbedResponseData = try Data(contentsOf: stubbedResponseURL)
        let stubbedResponse = try ProductsAPIResponse(json: stubbedResponseData.json())
        given(mockClient.fetchProductsData()).willReturn(.just(stubbedResponse))
    }

    private func stubClientProductsDataResponse(with error: NabuNetworkError) throws {
        given(mockClient.fetchProductsData()).willReturn(.failure(error))
    }
}
