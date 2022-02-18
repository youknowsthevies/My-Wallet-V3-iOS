// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension String {
    var substring: Substring { self[...] }
}

extension Substring {
    var string: String { String(self) }
}

extension StringProtocol {

    func dot(_ suffix: String) -> String {
        "\(self).\(suffix)"
    }

    func dotPath(after: String) -> SubSequence {
        guard count >= after.count else { return self[...] }
        guard hasPrefix(after) else { return self[...] }
        guard count > after.count else { return "" }
        let i = index(startIndex, offsetBy: after.count)
        guard i < endIndex, self[i] == "." else { return self[...] }
        return suffix(from: index(after: i))
    }

    func suffixAfterLastDot() -> SubSequence {
        guard let i = lastIndex(of: ".") else { return self[...] }
        return suffix(from: index(after: i))
    }

    func splitIfNotEmpty(separator: Character = ".") -> [SubSequence] {
        isEmpty ? [] : split(separator: ".", omittingEmptySubsequences: true)
    }

    func isDotPathAncestor(of other: String) -> Bool {
        guard other.count > count + 1 else { return false }
        guard other.hasPrefix(self) else { return false }
        return other[other.index(other.startIndex, offsetBy: count)] == "."
    }

    func isDotPathDescendant(of other: String) -> Bool {
        other.isDotPathAncestor(of: String(self))
    }
}

extension Sequence where Element == Substring {

    var string: [String] { map(\.string) }
}
