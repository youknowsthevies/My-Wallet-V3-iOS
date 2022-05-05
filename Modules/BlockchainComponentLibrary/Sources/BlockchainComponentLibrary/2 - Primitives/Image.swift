// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import SwiftUI

public enum Backport {}

extension View {
    public var backport: Backport.ContentView<Self> { Backport.ContentView(content: self) }
}

extension Backport {

    @available(iOS, deprecated: 15.0, renamed: "SwiftUI.AsyncImagePhase")
    @available(macOS, deprecated: 12.0, renamed: "SwiftUI.AsyncImagePhase")
    public enum AsyncImagePhase {
        case empty
        case success(Image)
        case failure(Error)
    }

    public struct ContentView<Content> where Content: View {
        let content: Content
    }

    @available(iOS, deprecated: 15.0, renamed: "SwiftUI.AsyncImage")
    @available(macOS, deprecated: 12.0, renamed: "SwiftUI.AsyncImage")
    public struct AsyncImage<Content>: View where Content: View {

        private let url: URL?
        private let scale: CGFloat
        private let transaction: Transaction
        private let content: (AsyncImagePhase) -> Content

        @StateObject private var loader: ImageLoader

        public init(
            url: URL?,
            scale: CGFloat = 1,
            transaction: Transaction = Transaction(),
            @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
        ) {
            self.url = url
            self.scale = scale
            self.transaction = transaction
            self.content = content
            _loader = .init(wrappedValue: .init(scale: scale))
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
}

extension Backport.AsyncImage where Content == Image {

    public init(url: URL?, scale: CGFloat = 1) {
        self.init(url: url, scale: scale) { phase in
            phase.image ?? Image("")
        }
    }
}

extension Backport.AsyncImage {

    public init<I, P>(
        url: URL?,
        scale: CGFloat = 1,
        content: @escaping (Image) -> I,
        placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P>, I: View, P: View {
        self.init(url: url, scale: scale) { phase in
            if let image = phase.image {
                content(image)
            } else {
                placeholder()
            }
        }
    }
}

extension Backport.AsyncImagePhase {

    public var image: Image? {
        switch self {
        case .success(let image):
            return image
        default:
            return nil
        }
    }

    public var error: Error? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
}

extension Backport {

    private class ImageLoader: ObservableObject {

        @Published private(set) var phase: Backport.AsyncImagePhase = .empty

        private let scale: CGFloat
        private var cancellable: AnyCancellable?

        init(scale: CGFloat) {
            self.scale = scale
        }

        deinit {
            cancel()
        }

        func load(resource: URL?) {
            switch resource {
            case nil:
                phase = .empty
            case let url?:
                cancellable = URLSession.shared.dataTaskPublisher(for: url)
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
                            if let image = self?.image(from: output.data) {
                                self?.phase = .success(image)
                            } else {
                                self?.phase = .empty
                            }
                        }
                    )
            }
        }

        private func image(from data: Data?) -> Image? {
            #if os(macOS)
            data
                .flatMap(NSImage.init(data:))
                .map(Image.init(nsImage:))
            #else
            data
                .flatMap { UIImage(data: $0, scale: scale) }
                .map(Image.init(uiImage:))
            #endif
        }

        func cancel() {
            cancellable?.cancel()
        }
    }
}

extension Backport.ContentView {
    /// Hides the separator on a `View` that is shown in
    /// a `List`.
    @ViewBuilder public func hideListRowSeparator() -> some View {
        #if os(iOS)
        if #available(iOS 15, *) {
            content
                .listRowSeparator(.hidden)
        } else {
            content
        }
        #else
        content
        #endif
    }

    /// Adds a `PrimaryDivider` at the bottom of the View.
    @ViewBuilder public func addPrimaryDivider() -> some View {
        if #available(iOS 15, *) {
            content
            PrimaryDivider()
        } else {
            content
        }
    }

    /// Hides the separator on a `View` that is shown in
    /// a `List` and adds a `PrimaryDivider` at the bottom of the View.
    @ViewBuilder public func hideListRowSepartorAndAddDivider() -> some View {
        #if os(iOS)
        if #available(iOS 15, *) {
            content
                .listRowSeparator(.hidden)
            PrimaryDivider()
        } else {
            content
        }
        #else
        content
        #endif
    }
}

struct BackportAsyncImage_Previews: PreviewProvider {

    static var url: URL? {
        URL(string: "http://httpbin.org/image/png")
    }

    static var previews: some View {
        VStack {
            Backport.AsyncImage(url: url, scale: 2.0)
                .frame(width: 100, height: 100)

            Backport.AsyncImage(
                url: url,
                content: {
                    $0.resizable()
                        .clipShape(Circle())
                },
                placeholder: {
                    Color.black
                }
            )
            .frame(width: 100, height: 100)

            Backport.AsyncImage(
                url: url,
                transaction: Transaction(animation: .linear),
                content: { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else if phase.error != nil {
                        Color.red
                    } else {
                        Color.blue
                    }
                }
            )
            .frame(width: 100, height: 100)
        }
    }
}
