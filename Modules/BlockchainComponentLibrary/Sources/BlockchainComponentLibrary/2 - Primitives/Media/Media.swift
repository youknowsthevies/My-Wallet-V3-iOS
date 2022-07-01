// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit
import CasePaths
import SwiftUI
import UniformTypeIdentifiers

public enum Media: View {

    case image(Image)
    case svg(SVG)
    case gif(GIF)
    case video(VideoPlayer<EmptyView>)

    @ViewBuilder public var body: some View {
        switch self {
        case .image(let image):
            image
        case .svg(let svg):
            svg
        case .gif(let gif):
            gif
        case .video(let video):
            video
        }
    }
}

public struct AsyncMedia<Content: View>: View {

    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncPhase<Media>) -> Content

    public init(
        url: URL?,
        scale: CGFloat = 1,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncPhase<Media>) -> Content
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }

    var uniformTypeIdentifier: UTType {
        url?.uniformTypeIdentifier ?? .image
    }

    @StateObject private var player = Player()

    public var body: some View {
        if uniformTypeIdentifier.conforms(to: .svg) {
            AsyncDataView(
                url: url,
                transaction: transaction,
                transform: SVG.init,
                content: { phase in content(phase.map(Media.svg)) }
            )
        } else if uniformTypeIdentifier.conforms(to: .gif) {
            AsyncDataView(
                url: url,
                transaction: transaction,
                transform: GIF.init,
                content: { phase in content(phase.map(Media.gif)) }
            )
        } else if uniformTypeIdentifier.conforms(to: .audiovisualContent) {
            if let url = url {
                if let player = player.av {
                    let videoPlayer = VideoPlayer<EmptyView>(player: player)
                    content(.success(.video(videoPlayer)))
                } else {
                    content(.empty)
                        .onAppear { player.av = AVPlayer(url: url) }
                }
            } else {
                content(.empty)
            }
        } else {
            AsyncDataView(
                url: url,
                transaction: transaction,
                transform: Image.init,
                content: { phase in content(phase.map(Media.image)) }
            )
        }
    }
}

extension AsyncMedia {

    class Player: ObservableObject {
        var av: AVPlayer?
    }
}

extension AsyncMedia {

    public init(
        url: URL?,
        scale: CGFloat = 1
    ) where Content == _ConditionalContent<Media, ProgressView<EmptyView, EmptyView>> {
        self.init(url: url, scale: scale, placeholder: { ProgressView() })
    }

    public init<I: View, P: View>(
        url: URL?,
        scale: CGFloat = 1,
        @ViewBuilder content: @escaping (Media) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P> {
        self.init(url: url, scale: scale) { phase in
            if case .success(let media) = phase {
                content(media)
            } else {
                placeholder()
            }
        }
    }

    public init<P: View>(
        url: URL?,
        scale: CGFloat = 1,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<Media, P> {
        self.init(
            url: url,
            scale: scale,
            content: { phase in
                if case .success(let media) = phase {
                    media
                } else {
                    placeholder()
                }
            }
        )
    }
}

extension URL {

    var uniformTypeIdentifier: UTType? { UTType(filenameExtension: pathExtension) }
}
