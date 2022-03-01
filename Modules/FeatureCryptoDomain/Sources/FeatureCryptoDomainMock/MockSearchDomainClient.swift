// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureCryptoDomainData
import Foundation
import NetworkError

// swiftlint:disable all
final class MockSearchDomainClient: SearchDomainClientAPI {

    var mockSearchResultResponseFilePath: String? {
        Bundle.module.path(forResource: "search_result_response_mock", ofType: "json")
    }

    func getSearchResults(searchKey: String) -> AnyPublisher<SearchResultResponse, NetworkError> {
        let data = try! Data(contentsOf: URL(fileURLWithPath: mockSearchResultResponseFilePath!), options: .mappedIfSafe)
        let response = try! JSONDecoder().decode(SearchResultResponse.self, from: data)
        return .just(response)
    }
}
