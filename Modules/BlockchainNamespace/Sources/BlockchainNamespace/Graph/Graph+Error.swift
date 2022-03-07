// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Graph {

    public struct Error: Swift.Error, CustomStringConvertible, CustomDebugStringConvertible {

        public let language: Date
        public let description: String
        public let function: StaticString
        public let file: StaticString
        public let line: UInt

        public var debugDescription: String {
            "\(description) @ \(file):\(line)"
        }

        public init(
            language: Date,
            description: String,
            function: StaticString = #function,
            file: StaticString = #fileID,
            line: UInt = #line
        ) {
            self.language = language
            self.description = description
            self.function = function
            self.file = file
            self.line = line
        }
    }
}
