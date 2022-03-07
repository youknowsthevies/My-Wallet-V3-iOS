import XCTest

extension Optional {

    func unwrap() throws -> Wrapped {
        try XCTUnwrap(self)
    }
}
