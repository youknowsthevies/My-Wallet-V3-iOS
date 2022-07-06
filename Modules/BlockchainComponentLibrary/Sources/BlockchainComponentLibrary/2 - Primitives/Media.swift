import AVKit
import SwiftUI
import UniformTypeIdentifiers

public enum Media: View {

    case image(Image)
    case svg(SVG)
    case video(VideoPlayer<EmptyView>)

    @ViewBuilder public var body: some View {
        switch self {
        case .image(let image):
            image
        case .svg(let svg):
            svg
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
            AsyncSVG(
                url: url,
                transaction: transaction,
                content: { phase in content(phase.map(Media.svg)) }
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
            Backport.AsyncImage(
                url: url,
                scale: scale,
                transaction: transaction,
                content: { phase in
                    content(phase.map { image in Media.image(image.resizable()) })
                }
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
    ) where Content == _ConditionalContent<Media, Icon> {
        self.init(url: url, scale: scale, placeholder: { Icon.error })
    }

    public init<I: View, P: View>(
        url: URL?,
        scale: CGFloat = 1,
        @ViewBuilder content: @escaping (Media) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P> {
        self.init(url: url, scale: scale) { phase in
            if let media = phase.media {
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
                if let media = phase.media {
                    media
                } else {
                    placeholder()
                }
            }
        )
    }
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

extension AsyncPhase where Success == Media {

    public var media: Media? {
        switch self {
        case .success(let media):
            return media
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

extension URL {

    var uniformTypeIdentifier: UTType? { UTType(filenameExtension: pathExtension) }
}
