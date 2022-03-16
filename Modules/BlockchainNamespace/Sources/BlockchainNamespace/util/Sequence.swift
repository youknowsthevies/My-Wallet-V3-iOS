// Copyright © Blockchain Luxembourg S.A. All rights reserved.
extension Sequence where Element: Equatable {

    func doesNotContain(_ element: Element) -> Bool {
        !contains(element)
    }
}

extension Sequence {

    func count(where predicate: (Element) -> Bool) -> Int {
        reduce(0) { predicate($1) ? $0 + 1 : $0 }
    }
}
