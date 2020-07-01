//
//  String+Conveniences.swift
//  PlatformKit
//
//  Created by Alex McGregor on 12/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// MARK: - Range

public extension String {
    func range(startingAt index: Int, length: Int) -> Range<String.Index>? {
        let range = NSRange(
            location: index,
            length: length
        )
        return Range(range, in: self)
    }
    
    subscript(bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript(bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}

public extension String {
    
    func count(of substring: String) -> Int {
        let components = self.components(separatedBy: substring)
        return components.count - 1
    }
    
    /// Returns query arguments from a string in URL format
    var queryArgs: [String: String] {
        var queryArgs = [String: String]()
        let components = self.components(separatedBy: "&")
        components.forEach {
            let paramValueArray = $0.components(separatedBy: "=")
            
            if paramValueArray.count == 2,
                let param = paramValueArray[0].removingPercentEncoding,
                let value = paramValueArray[1].removingPercentEncoding {
                queryArgs[param] = value
            }
        }
        
        return queryArgs
    }
    
    /// Removes last char safely
    mutating func removeLastSafely() {
        guard !isEmpty else { return }
        removeLast()
    }

    func removing(prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(suffix(count - prefix.count))
    }
    
    /// Returns the string with no whitespaces
    var trimmingWhitespaces: String {
        trimmingCharacters(in: .whitespaces)
    }
}

extension String {
    public var isAlphanumeric: Bool {
        guard !isEmpty else {
            return false
        }
        guard rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil else {
            return false
        }
        return true
    }
}

extension String {
    public func escapedForJS(wrapInQuotes: Bool = false) -> String {
        var output = self
        let insensitive = NSString.CompareOptions.caseInsensitive
        output = output
            .replacingOccurrences(of: "\\", with: "\\\\", options: insensitive)    // Reverse solidus
            .replacingOccurrences(of: "\"", with: "\\\"", options: insensitive)    // Quotation mark
            .replacingOccurrences(of: "'", with: "\\'", options: insensitive)      // Single quote
            .replacingOccurrences(of: "\u{8}", with: "\\b", options: insensitive)  // Backspace
            .replacingOccurrences(of: "\u{12}", with: "\\f", options: insensitive) // Formfeed
            .replacingOccurrences(of: "\n", with: "\\n", options: insensitive)     // Newline
            .replacingOccurrences(of: "\r", with: "\\r", options: insensitive)     // Carriage return
            .replacingOccurrences(of: "\t", with: "\\t", options: insensitive)     // Horizontal tab
        return wrapInQuotes ? "\"\(output)\"" : output
    }
}
