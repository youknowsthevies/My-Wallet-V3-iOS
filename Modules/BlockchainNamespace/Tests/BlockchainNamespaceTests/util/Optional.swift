import XCTest

extension Optional {

    func unwrap(_ file: StaticString = #file, _ line: UInt = #line) throws -> Wrapped {
        try XCTUnwrap(self, file: file, line: line)
    }
}
