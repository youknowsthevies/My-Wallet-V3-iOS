// Copyright © Blockchain Luxembourg S.A. All rights reserved.
extension String {

    var isNotEmpty: Bool { !isEmpty }

    func dot(_ suffix: String) -> String {
        "\(self).\(suffix)"
    }

    func suffixAfterLastDot() -> Substring {
        guard let i = lastIndex(of: ".") else { return self[...] }
        return suffix(from: index(after: i))
    }

    func splitIfNotEmpty(separator: Character = ".") -> [Substring] {
        isEmpty ? [] : split(separator: ".", omittingEmptySubsequences: true)
    }
}

extension Sequence where Element == Substring {

    var string: [String] {
        map(\.string)
    }
}

extension Substring {

    var string: String {
        String(self)
    }
}
