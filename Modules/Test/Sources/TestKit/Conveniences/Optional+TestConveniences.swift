// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension Optional where Wrapped: AdditiveArithmetic {

    public static var zero: Wrapped {
        Wrapped.zero
    }

    public static func + (lhs: Wrapped?, rhs: Wrapped?) -> Wrapped {
        (lhs ?? zero) + (rhs ?? zero)
    }

    public static func - (lhs: Wrapped?, rhs: Wrapped?) -> Wrapped {
        (lhs ?? zero) - (rhs ?? zero)
    }
}

extension Optional {

    public func unwrap(
        _ message: @autoclosure () -> String = "",
        _ file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Wrapped {
        try XCTUnwrap(self, message(), file: file, line: line)
    }
}
