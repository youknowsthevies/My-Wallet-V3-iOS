@testable import BlockchainNamespace
import Combine
import XCTest

final class BlockchainNamespaceTests: XCTestCase {

    func test_language() {
        XCTAssertEqual(blockchain(\.id), "blockchain")
        XCTAssertEqual(blockchain.user(\.id), "blockchain.user")
        XCTAssertEqual(blockchain.user.email.address(\.id), "blockchain.user.email.address")
        XCTAssertEqual(blockchain.user.email[].description, "blockchain.user.email")
    }
}
