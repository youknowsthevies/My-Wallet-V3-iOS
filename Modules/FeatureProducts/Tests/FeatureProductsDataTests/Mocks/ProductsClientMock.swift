import Combine
import Errors
import FeatureProductsData
import ToolKit

final class ProductsClientMock: ProductsClientAPI {

    struct RecordedInvocations {
        var fetchProductsData: [Void] = []
    }

    struct StubbedResults {
        var fetchProductsData: AnyPublisher<ProductsAPIResponse, NabuNetworkError> = .empty()
    }

    private(set) var recordedInvocations = RecordedInvocations()
    var stubbedResults = StubbedResults()

    func fetchProductsData() -> AnyPublisher<ProductsAPIResponse, NabuNetworkError> {
        recordedInvocations.fetchProductsData.append(())
        return stubbedResults.fetchProductsData
    }
}
