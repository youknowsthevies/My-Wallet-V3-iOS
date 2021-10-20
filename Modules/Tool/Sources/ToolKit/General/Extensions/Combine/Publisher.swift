// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

extension Publisher where Failure == Never {

    public func sink<Root>(
        to handler: @escaping (Root) -> (Output) -> Void,
        on root: Root
    ) -> AnyCancellable where Root: AnyObject {
        sink { [weak root] value in
            guard let root = root else { return }
            handler(root)(value)
        }
    }

    public func sink<Root>(
        to handler: @escaping (Root) -> () -> Void,
        on root: Root
    ) -> AnyCancellable where Root: AnyObject {
        sink { [weak root] _ in
            guard let root = root else { return }
            handler(root)()
        }
    }
}

extension Publisher {

    public func sink<Root>(
        completion completionHandler: @escaping (Root) -> (Subscribers.Completion<Failure>) -> Void,
        receiveValue receiveValueHandler: @escaping (Root) -> (Output) -> Void,
        on root: Root
    ) -> AnyCancellable where Root: AnyObject {
        sink { [weak root] completion in
            guard let root = root else { return }
            completionHandler(root)(completion)
        } receiveValue: { [weak root] output in
            guard let root = root else { return }
            receiveValueHandler(root)(output)
        }
    }
}

extension Publisher {

    public func `catch`(_ handler: @escaping (Failure) -> Output) -> Publishers.Catch<Self, Just<Output>> {
        `catch` { error in Just(handler(error)) }
    }
}
