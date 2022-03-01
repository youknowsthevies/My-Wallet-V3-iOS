// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureCryptoDomainData
@testable import FeatureCryptoDomainDomain
@testable import FeatureCryptoDomainMock
import TestKit
import XCTest

class SearchDomainRepositoryTests: XCTestCase {

    var client: SearchDomainClientAPI!
    var repository: SearchDomainRepositoryAPI!

    override func setUpWithError() throws {
        try super.setUpWithError()
        client = MockSearchDomainClient()
        repository = SearchDomainRepository(apiClient: client)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        client = nil
        repository = nil
    }

    func test_search_domain_dto() {
        let publisher = repository.searchResults(searchKey: "")
        let expectedResult = mockSearchDomainResults
        XCTAssertPublisherValues(publisher, expectedResult)
    }
}
