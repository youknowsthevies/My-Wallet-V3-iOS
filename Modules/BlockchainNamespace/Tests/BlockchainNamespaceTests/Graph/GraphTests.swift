import BlockchainNamespace
import XCTest

final class GraphTests: XCTestCase {

    let date = Date(timeIntervalSinceReferenceDate: 666824886.181533)

    func test_load_json() throws {

        let graph = try Graph(json: .test)

        XCTAssertEqual(graph.date, date)
        XCTAssertEqual(graph.root.id, "blockchain")

        let string = try graph.nodes["blockchain.type.string"].unwrap()
        let boolean = try graph.nodes["blockchain.type.boolean"].unwrap()
        let stored = try graph.nodes["blockchain.test.schema.stored"].unwrap()

        do {
            let test = try graph.nodes["blockchain.test.schema.string"].unwrap()
            XCTAssertTrue(test.is(string))
        }

        do {
            let test = try graph.nodes["blockchain.test.schema.boolean"].unwrap()
            XCTAssertTrue(test.is(boolean))
        }

        do {
            let test = try graph.nodes["blockchain.test.schema.stored_boolean"].unwrap()
            XCTAssertTrue(test.is(boolean))
            XCTAssertTrue(test.is(stored))
        }
    }

    func test_load_no_root() throws {
        do {
            let json = try Graph.JSON.from(
                json: Data(#"{"classes":[],"date":666824886.181533}"#.utf8)
            )
            _ = try Graph(json: json)
        } catch let error as Graph.Error {
            XCTAssertEqual(error.description, "Graph 2022-02-17 21:08:06 +0000 does not have a root node")
        }
    }

    func test_load_two_root() throws {
        do {
            let json = try Graph.JSON.from(
                json: Data(#"{"classes":[{"id":"blockchain"}, {"id":"blockchain_2"}],"date":666824886.181533}"#.utf8)
            )
            _ = try Graph(json: json)
        } catch let error as Graph.Error {
            XCTAssertEqual(error.description, "Found two roots: 'blockchain_2' and 'blockchain'")
        }
    }
}

extension Graph.JSON {
    // swiftlint:disable force_try
    static var test: Self = try! .from(json: __data)
}

let __data = Data(
    """
    {
      "classes" : [
        {
          "children" : [
            "test",
            "type"
          ],
          "id" : "blockchain"
        },
        {
          "children" : [
            "schema"
          ],
          "id" : "blockchain.test"
        },
        {
          "children" : [
            "boolean",
            "string",
            "stored",
            "stored_boolean"
          ],
          "id" : "blockchain.test.schema"
        },
        {
          "id" : "blockchain.test.schema.boolean",
          "supertype" : "blockchain.type.boolean",
          "type" : [
            "blockchain.type.boolean"
          ]
        },
        {
          "id" : "blockchain.test.schema.string",
          "supertype" : "blockchain.type.string",
          "type" : [
            "blockchain.type.string"
          ]
        },
        {
          "id" : "blockchain.test.schema.stored"
        },
        {
          "id" : "blockchain.test.schema.stored_boolean",
          "supertype" : "blockchain.type.boolean_&_blockchain.test.schema.stored",
          "type" : [
            "blockchain.test.schema.stored",
            "blockchain.type.boolean"
          ]
        },
        {
          "id" : "blockchain.type.boolean_&_blockchain.test.schema.stored",
          "mixin" : {
            "type" : "blockchain.test.schema.stored"
          },
          "supertype" : "blockchain.type.boolean"
        },
        {
          "children" : [
            "boolean",
            "string"
          ],
          "id" : "blockchain.type"
        },
        {
          "id" : "blockchain.type.boolean"
        },
        {
          "id" : "blockchain.type.string"
        },
      ],
      "date" : 666824886.18153298,
      "name" : "blockchain"
    }
    """.utf8
)
