// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureTransactionDomain
@testable import FeatureTransactionDomainMock
@testable import PlatformKitMock
import TestKit
import XCTest

final class BlockchainNameResolutionServiceTests: XCTestCase {

    var subject: BlockchainNameResolutionService!
    var factoryMock: ExternalAssetAddressServiceMock!
    var repositoryMock: MockBlockchainNameResolutionRepository!

    override func setUp() {
        super.setUp()
        factoryMock = .init()
        repositoryMock = .init()
        subject = .init(
            repository: repositoryMock,
            factory: factoryMock
        )
    }

    func testNameResolutionWithEmoji() {
        let domain = "y.at/⚽️⚽️⚽️"
        let e = expectation(description: "Completion Block Called")
        repositoryMock.underlyingResolve = { domainName, currency in
            XCTAssertEqual(domainName, domain)
            e.fulfill()
            return .just(.init(currency: currency, address: "address"))
        }
        let publisher = subject.validate(domainName: domain, currency: .bitcoin)
        XCTAssertPublisherCompletion(publisher)

        wait(for: [e], timeout: 10)
    }
}
