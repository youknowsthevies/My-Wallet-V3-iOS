// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import SwiftUI

public protocol OptionalDataInit {
    init?(_ data: Data?)
}

public struct AsyncDataView<Success, Content>: View where Content: View {

    private let url: URL?
    private let transaction: Transaction
    private let content: (AsyncPhase<Success>) -> Content

    @StateObject private var loader: AsyncDataLoader<Success>

    public init(
        url: URL?,
        transaction: Transaction = Transaction(),
        session: URLSession = .shared,
        transform: @escaping (Data?) -> Success?,
        @ViewBuilder content: @escaping (AsyncPhase<Success>) -> Content
    ) {
        self.url = url
        self.transaction = transaction
        self.content = content
        _loader = .init(wrappedValue: .init(session: session, transform: transform))
    }

    public var body: some View {
        withTransaction(transaction) {
            content(loader.phase)
        }
        .onChange(of: url) { url in
            loader.load(resource: url)
        }
        .onAppear {
            loader.load(resource: url)
        }
        .id(url)
    }
}

extension AsyncDataView {

    public init(
        url: URL?,
        transform: @escaping (Data?) -> Success?
    ) where Content == _ConditionalContent<Success, ProgressView<EmptyView, EmptyView>>, Success: View {
        self.init(url: url, transform: transform, placeholder: { ProgressView() })
    }

    public init<I: View, P: View>(
        url: URL?,
        transform: @escaping (Data?) -> Success?,
        @ViewBuilder content: @escaping (Success) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P> {
        self.init(url: url, transform: transform) { phase in
            if case .success(let view) = phase {
                content(view)
            } else {
                placeholder()
            }
        }
    }

    public init<P: View>(
        url: URL?,
        transform: @escaping (Data?) -> Success?,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<Success, P>, Success: View {
        self.init(
            url: url,
            transform: transform,
            content: { phase in
                if case .success(let view) = phase {
                    view
                } else {
                    placeholder()
                }
            }
        )
    }
}

extension AsyncDataView where Success: OptionalDataInit {

    public init(
        url: URL?,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncPhase<Success>) -> Content
    ) {
        self.init(url: url, transaction: transaction, transform: Success.init, content: content)
    }

    public init(
        url: URL?
    ) where Content == _ConditionalContent<Success, ProgressView<EmptyView, EmptyView>>, Success: View {
        self.init(url: url, transform: Success.init, placeholder: { ProgressView() })
    }

    public init<I: View, P: View>(
        url: URL?,
        @ViewBuilder content: @escaping (Success) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P> {
        self.init(url: url, transform: Success.init) { phase in
            if case .success(let view) = phase {
                content(view)
            } else {
                placeholder()
            }
        }
    }

    public init<P: View>(
        url: URL?,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<Success, P>, Success: View {
        self.init(
            url: url,
            transform: Success.init,
            content: { phase in
                if case .success(let view) = phase {
                    view
                } else {
                    placeholder()
                }
            }
        )
    }
}

public enum AsyncPhase<Success> {
    case empty
    case success(Success)
    case failure(Error)
}

extension AsyncPhase {

    @inlinable public func map<T>(_ transform: (Success) -> T) -> AsyncPhase<T> {
        switch self {
        case .empty:
            return .empty
        case .success(let success):
            return .success(transform(success))
        case .failure(let error):
            return .failure(error)
        }
    }

    @inlinable public func flatMap<T>(_ transform: (Success) -> AsyncPhase<T>) -> AsyncPhase<T> {
        switch self {
        case .empty:
            return .empty
        case .success(let success):
            return transform(success)
        case .failure(let error):
            return .failure(error)
        }
    }
}

private class AsyncDataLoader<Success>: ObservableObject {

    @Published private(set) var phase: AsyncPhase<Success> = .empty

    private let session: URLSession
    private let transform: (Data) -> Success?
    private var cancellable: AnyCancellable?

    init(
        session: URLSession = .shared,
        transform: @escaping (Data?) -> Success?
    ) {
        self.session = session
        self.transform = transform
    }

    deinit { cancel() }

    func load(resource: URL?) {
        switch resource {
        case nil:
            phase = .empty
        case let url?:
            cancellable = session.dataTaskPublisher(for: url)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        switch completion {
                        case .failure(let error):
                            self?.phase = .failure(error)
                        case .finished:
                            break
                        }
                    },
                    receiveValue: { [weak self] output in
                        if let value = self?.transform(output.data) {
                            self?.phase = .success(value)
                        } else {
                            self?.phase = .empty
                        }
                    }
                )
        }
    }

    func cancel() {
        cancellable?.cancel()
    }
}
