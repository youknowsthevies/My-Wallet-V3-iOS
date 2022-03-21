import Combine
import FeatureProductsDomain
import NabuNetworkError
import ToolKit

final class ProductsRepositoryMock: ProductsRepositoryAPI {

    struct RecordedInvocations {
        var fetchProducts: [Void] = []
        var streamProducts: [Void] = []
    }

    struct StubbedResponses {
        var fetchProducts: AnyPublisher<[ProductValue], NabuNetworkError> = .empty()
        var streamProducts: AnyPublisher<Result<[ProductValue], NabuNetworkError>, Never> = .empty()
    }

    private(set) var recordedInvocations = RecordedInvocations()
    var stubbedResponses = StubbedResponses()

    func fetchProducts() -> AnyPublisher<[ProductValue], NabuNetworkError> {
        recordedInvocations.fetchProducts.append(())
        return stubbedResponses.fetchProducts
    }

    func streamProducts() -> AnyPublisher<Result<[ProductValue], NabuNetworkError>, Never> {
        recordedInvocations.streamProducts.append(())
        return stubbedResponses.streamProducts
    }
}
