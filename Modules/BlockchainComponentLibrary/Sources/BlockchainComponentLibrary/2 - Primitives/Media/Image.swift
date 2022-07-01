// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import SwiftUI

public enum Backport {}

extension View {
    public var backport: Backport.ContentView<Self> { Backport.ContentView(content: self) }
}

extension Image: OptionalDataInit {

    public init?(_ data: Data?) {
        #if canImport(AppKit)
        guard let image = data
            .flatMap(NSImage.init(data:))
            .map(Image.init(nsImage:))
        else { return nil }
        #else
        guard let image = data
            .flatMap(UIImage.init(data:))
            .map(Image.init(uiImage:))
        else { return nil }
        #endif
        self = image
    }
}

extension Backport {
    public struct ContentView<Content> where Content: View {
        let content: Content
    }

    @available(iOS, deprecated: 15.0, renamed: "SwiftUI.AsyncImage")
    @available(macOS, deprecated: 12.0, renamed: "SwiftUI.AsyncImage")
    public typealias AsyncImage<Content: View> = AsyncDataView<Image, Content>
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
        Backport.AsyncImage(url: url)
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
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    Color.red
                case .empty:
                    Color.blue
                }
            }
        )
        .frame(width: 100, height: 100)
    }
}
