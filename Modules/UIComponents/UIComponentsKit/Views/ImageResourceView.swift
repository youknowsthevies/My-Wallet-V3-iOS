// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import SwiftUI

#if canImport(UIKit)
private let makeImage = Image.init(uiImage:)
#elseif canImport(AppKit)
private let makeImage = Image.init(nsImage:)
#endif

public struct ImageResourceView<Loading: View, Placeholder: View>: View {

    @StateObject private var loader: ImageLoader
    private let placeholder: () -> Placeholder
    private let loading: () -> Loading
    private var image: (UniversalImage) -> Image = makeImage

    public init(
        resource: ImageResource,
        @ViewBuilder loading: @escaping () -> Loading,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.loading = loading
        self.placeholder = placeholder
        _loader = StateObject(wrappedValue: ImageLoader(resource: resource))
    }

    public var body: some View {
        content.onAppear(perform: loader.load)
    }

    @ViewBuilder private var content: some View {
        if loader.isLoading {
            loading()
        } else if let o = loader.image {
            image(o).resizable()
        } else {
            placeholder()
        }
    }
}

extension ImageResourceView {

    public init?(
        systemName: String,
        @ViewBuilder loading: @escaping () -> Loading,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(resource: .systemName(systemName), loading: loading, placeholder: placeholder)
    }

    public init?(
        named name: String,
        in bundle: Bundle,
        @ViewBuilder loading: @escaping () -> Loading,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(resource: .local(name: name, bundle: bundle), loading: loading, placeholder: placeholder)
    }

    public init(
        url: URL,
        @ViewBuilder loading: @escaping () -> Loading,
        placeholder: @autoclosure @escaping () -> Placeholder
    ) {
        self.init(resource: .remote(url: url), loading: loading, placeholder: placeholder)
    }

    public init(
        _ resource: ImageResource,
        @ViewBuilder loading: @escaping () -> Loading,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(resource: resource, loading: loading, placeholder: placeholder)
    }
}

extension ImageResourceView where Loading == ProgressView<EmptyView, EmptyView> {

    public init?(
        systemName: String,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(.systemName(systemName), placeholder: placeholder)
    }

    public init?(
        named name: String,
        in bundle: Bundle,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(.local(name: name, bundle: bundle), placeholder: placeholder)
    }

    public init(
        url: URL,
        placeholder: @autoclosure @escaping () -> Placeholder
    ) {
        self.init(.remote(url: url), placeholder: placeholder)
    }

    public init(
        url: URL,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(.remote(url: url), placeholder: placeholder)
    }

    public init(
        _ resource: ImageResource,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(resource: resource, loading: ProgressView.init, placeholder: placeholder)
    }
}

extension ImageResourceView where Loading == ProgressView<EmptyView, EmptyView>, Placeholder == Color {

    public init(systemName: String) {
        self.init(.systemName(systemName))
    }

    public init(named name: String, in bundle: Bundle) {
        self.init(.local(name: name, bundle: bundle))
    }

    public init(url: URL) {
        self.init(.remote(url: url))
    }

    public init(_ resource: ImageResource) {
        self.init(resource: resource, loading: ProgressView.init, placeholder: { Color.gray })
    }
}

private class ImageLoader: ObservableObject {

    @Published var image: UniversalImage?

    private(set) var isLoading = false

    private let resource: ImageResource
    private var cancellable: AnyCancellable?

    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")

    init(resource: ImageResource) {
        self.resource = resource
    }

    deinit {
        cancel()
    }

    func load() {
        guard !isLoading else { return }

        switch resource {
        case .local(name: let name, bundle: let bundle):
            image = UniversalImage(named: name, in: bundle, compatibleWith: nil)
            onFinish()
        case .systemName(let name):
            image = UniversalImage(systemName: name)
            onFinish()
        case .remote(url: let url):
            cancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { UniversalImage(data: $0.data) }
                .replaceError(with: nil)
                .handleEvents(
                    receiveSubscription: { [weak self] _ in self?.onStart() },
                    receiveCompletion: { [weak self] _ in self?.onFinish() },
                    receiveCancel: { [weak self] in self?.onFinish() }
                )
                .subscribe(on: Self.imageProcessingQueue)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.image = $0 }
        }
    }

    func cancel() {
        cancellable?.cancel()
    }

    private func onStart() {
        isLoading = true
    }

    private func onFinish() {
        isLoading = false
    }
}

struct ImageResourceView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ImageResourceView(named: "cancel_icon", in: .module)
                .aspectRatio(contentMode: .fit)
                .frame(width: 20)
            ImageResourceView(
                url: URL(string: "https://www.blockchain.com/static/img/home/products/wallet-buy@2x.png")!
            )
            .aspectRatio(contentMode: .fit)
        }
    }
}
