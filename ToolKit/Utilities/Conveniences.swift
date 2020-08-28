//
//  Conveniences.swift
//  ToolKit
//
//  Created by Jack Pooley on 17/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Unconditionally prints an unimplemented message and stops execution.
/// This is useful when and API is only partially implemented.
///
/// - Parameters:
///   - file: The file name to print with `message`. The default is the file
///     where `unimplemented(file:line:)` is called.
///   - line: The line number to print along with `message`. The default is the
///     line number where `unimplemented(file:line:)` is called.
public func unimplemented(file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("Not implemented.", file: file, line: line)
}

/// Unconditionally prints an impossible state message and stops execution.
/// This is useful when and API is only partially implemented.
///
/// - Parameters:
///   - file: The file name to print with `message`. The default is the file
///     where `unimplemented(file:line:)` is called.
///   - line: The line number to print along with `message`. The default is the
///     line number where `unimplemented(file:line:)` is called.
public func impossible(file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("Impossible state.", file: file, line: line)
}
