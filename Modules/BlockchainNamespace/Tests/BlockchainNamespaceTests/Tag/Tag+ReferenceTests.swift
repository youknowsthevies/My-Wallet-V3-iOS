@testable import BlockchainNamespace
import XCTest

final class TagReferenceTests: XCTestCase {

    let app = App()

    func test_reference_to_user() throws {

        let ref = try blockchain.user.name.first[]
            .ref(to: [blockchain.user.id: "Dorothy"])
            .validated()

        XCTAssertNil(ref.error)
        XCTAssertEqual(ref.indices[blockchain.user.id], "Dorothy")
        XCTAssertEqual(ref.string, "blockchain.user[Dorothy].name.first")
        XCTAssertEqual(ref.id(), "blockchain.user.name.first")
        XCTAssertEqual(ref.id(ignoring: []), "blockchain.user[Dorothy].name.first")
    }

    func test_reference_with_invalid_indices() throws {
        let ref = blockchain.user.name.first[].ref()
        XCTAssertThrowsError(try ref.validated())
        XCTAssertNotNil(ref.error)
    }

    func test_reference_to_user_with_additional_context() throws {

        let ref = blockchain.user.name.first[]
            .ref(
                to: [
                    blockchain.user.id: "Dorothy",
                    blockchain.app.configuration.apple.pay.is.enabled: true
                ]
            )

        XCTAssertEqual(ref.indices, [blockchain.user.id[]: "Dorothy"])

        XCTAssertAnyEqual(
            ref.context,
            [
                blockchain.user.id[]: "Dorothy",
                blockchain.app.configuration.apple.pay.is.enabled[]: true
            ]
        )
    }

    func test_init_id() throws {
        let ref = try Tag.Reference(id: "blockchain.user[Dorothy].name.first", in: app.language)
        XCTAssertEqual(ref.string, "blockchain.user[Dorothy].name.first")
    }

    func test_init_id_missing_indices() throws {
        do {
            let ref = try Tag.Reference(id: "blockchain.user.name.first", in: app.language)
            XCTAssertEqual(ref.string, "blockchain.user.name.first")
            try ref.validated()
        } catch let error as Tag.Error {
            XCTAssertEqual(error.message(), "Missing index blockchain.user.id for ref to blockchain.user.name.first")
        }
    }

    func test_ref_fetch_indices_from_state() throws {

        app.state.set(blockchain.user.id, to: "Dorothy")

        let ref = try blockchain.user.name.first[]
            .ref(in: app)
            .validated()

        XCTAssertEqual(ref.indices[blockchain.user.id], "Dorothy")
    }
}
