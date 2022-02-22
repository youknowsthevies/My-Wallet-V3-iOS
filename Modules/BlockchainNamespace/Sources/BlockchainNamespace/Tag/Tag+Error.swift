// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension Tag {

    public struct Error: Swift.Error, CustomStringConvertible, CustomDebugStringConvertible {

        let tag: Tag
        let message: () -> String

        let function: String, file: String, line: Int

        init(
            tag: Tag,
            message: @autoclosure @escaping () -> String = "",
            _ function: String = #function,
            _ file: String = #file,
            _ line: Int = #line
        ) {
            self.tag = tag
            self.message = message
            self.function = function
            self.file = file
            self.line = line
        }

        public var description: String { message() }

        public var debugDescription: String {
            "\(file):\(line) \(tag.id): \(message())"
        }
    }

    public func error(
        message: @autoclosure @escaping () -> String = "",
        _ function: String = #function,
        _ file: String = #file,
        _ line: Int = #line
    ) -> Tag.Error {
        .init(tag: self, message: message(), function, file, line)
    }
}
