// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol AnalyticsEvent {
    var timestamp: Date? { get }
    var name: String { get }
    var params: [String: Any]? { get }
    var type: AnalyticsEventType { get }
}

public extension AnalyticsEvent {
    var type: AnalyticsEventType {
        .firebase
    }

    var timestamp: Date? {
        nil
    }

    var name: String {
        (Mirror(reflecting: self).children.first?.label ?? String(describing: self)).camelCaseToSpaceCase()
    }

    var params: [String: Any]? {
        guard type == .nabu else {
            return nil
        }
        var params = [String: Any]()
        let reflection = Mirror(reflecting: self)
        guard reflection.displayStyle == .enum, let associated = reflection.children.first else {
            return params
        }
        Mirror(reflecting: associated.value).children
            .forEach {
                if let label = $0.label?.camelCaseToSnakeCase() {
                    if let value = $0.value as? StringRawRepresentable {
                        params[label] = value.rawValue
                    } else {
                        params[label] = $0.value
                    }
                }
            }
        return params
    }
}

public protocol StringRawRepresentable {
    var rawValue: String { get }
}

fileprivate extension String {
    var acronymPattern: String {
        "([A-Z]+)([A-Z][a-z]|[0-9])"
    }
    var fullWordsPattern: String {
        "([a-z])([A-Z]|[0-9])"
    }
    var digitsFirstPattern: String {
        "([0-9])([A-Z])"
    }

    func camelCaseToSnakeCase() -> String {
        let template = "$1_$2"
        return processCamelCaseRegex(pattern: acronymPattern, withTemplate: template)?
            .processCamelCaseRegex(pattern: fullWordsPattern, withTemplate: template)?
            .processCamelCaseRegex(pattern: digitsFirstPattern, withTemplate: template)?
            .lowercased() ?? lowercased()
    }

    func camelCaseToSpaceCase() -> String {
        let template = "$1 $2"
        return capitalizingFirstLetter()
            .processCamelCaseRegex(pattern: acronymPattern, withTemplate: template)?
            .processCamelCaseRegex(pattern: fullWordsPattern, withTemplate: template)?
            .processCamelCaseRegex(pattern: digitsFirstPattern, withTemplate: template) ?? self
    }

    private func processCamelCaseRegex(pattern: String, withTemplate: String ) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: withTemplate)
    }

    private func capitalizingFirstLetter() -> String {
        prefix(1).capitalized + dropFirst()
    }
}
