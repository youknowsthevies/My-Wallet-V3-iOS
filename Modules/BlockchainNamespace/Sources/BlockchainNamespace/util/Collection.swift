// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension RandomAccessCollection {
    var isNotEmpty: Bool { !isEmpty }
}

extension Collection where Element: Hashable {
    var set: Set<Element> { Set(self) }
}

extension Collection {
    var array: [Element] { Array(self) }
}
