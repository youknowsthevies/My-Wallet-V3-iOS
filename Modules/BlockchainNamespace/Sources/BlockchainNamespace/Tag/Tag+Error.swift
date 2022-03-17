// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Tag {

    public struct Error: Swift.Error, CustomStringConvertible, CustomDebugStringConvertible, LocalizedError {

        let tag: Tag
        let context: Tag.Context

        let message: String
        let file: String, line: Int

        init(
            tag: Tag,
            context: Tag.Context = [:],
            message: @autoclosure () -> String = "",
            _ file: String = #fileID,
            _ line: Int = #line
        ) {
            self.tag = tag
            self.context = context
            self.message = message()
            self.file = file
            self.line = line
        }

        public var description: String { message }
        public var errorDescription: String? { message }

        public var debugDescription: String {
            "\(file):\(line) \(tag): \(message)"
        }
    }

    public func error(
        message: @autoclosure () -> String = "",
        file: String = #fileID,
        line: Int = #line
    ) -> Tag.Error {
        .init(tag: self, message: message(), file, line)
    }
}

extension Tag.Reference {

    public func error(
        message: @autoclosure () -> String = "",
        file: String = #fileID,
        line: Int = #line
    ) -> Tag.Error {
        .init(tag: tag, context: context, message: message(), file, line)
    }
}
