// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public class Reference<T> {

    public let valueDidChange$ = PassthroughSubject<T, Never>()
    public var value: T {
        didSet { valueDidChange$.send(value) }
    }

    public init(_ value: inout T) {
        self.value = value
    }
}

public class Weak<T> where T: AnyObject {

    public weak var value: T?

    public init(_ value: T?) {
        self.value = value
    }
}
