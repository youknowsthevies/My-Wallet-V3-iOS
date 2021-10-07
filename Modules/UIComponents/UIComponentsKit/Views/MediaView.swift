// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit
import SwiftUI
import ToolKit

public struct Media: Codable, Hashable {
    public var image: Image?
    public var video: Video?
}

extension Media {

    public struct Image: Codable, Hashable {

        public struct Placeholder: Codable, Hashable {
            public var name: String?
            public var systemName: String?
        }

        public var name: String?
        public var systemName: String?
        public var url: URL?
        public var placeholder: Placeholder?
    }

    public static func image(at url: URL, placeholder: Media.Image.Placeholder? = nil) -> Self {
        Media(image: Media.Image(url: url, placeholder: placeholder))
    }

    public static func image(named name: String) -> Self {
        Media(image: Media.Image(name: name))
    }

    public static func image(systemName name: String) -> Self {
        Media(image: Media.Image(systemName: name))
    }
}

extension Media.Image.Placeholder {

    public static func named(_ name: String) -> Self {
        .init(name: name)
    }

    public static func systemName(_ name: String) -> Self {
        .init(systemName: name)
    }
}

extension Media {

    public struct Video: Codable, Hashable {
        public var name: String?
        public var url: URL?
    }

    public static func video(at url: URL) -> Self {
        Media(video: Media.Video(url: url))
    }

    public static func video(named name: String) -> Self {
        Media(video: Media.Video(name: name))
    }
}

public struct MediaView<Failure: View>: View {

    @State public var media: Media

    public let bundle: Bundle
    public let failure: () -> Failure

    public init(
        _ media: Media,
        in bundle: Bundle = .main,
        failure: @autoclosure @escaping () -> Failure
    ) {
        self.init(media, in: bundle, failure: failure)
    }

    public init(
        _ media: Media,
        in bundle: Bundle = .main,
        @ViewBuilder failure: @escaping () -> Failure
    ) {
        _media = .init(initialValue: media)
        self.bundle = bundle
        self.failure = failure
    }

    public var body: some View {
        if let video = media.video {
            Video(video)
        } else if let image = media.image {
            Image(image)
        } else {
            failure()
        }
    }

    @ViewBuilder
    private func Image(_ image: Media.Image) -> some View {
        if let url = image.url {
            if let name = image.placeholder?.name, UniversalImage(named: name, in: bundle, with: nil) != nil {
                ImageResourceView(url: url, placeholder: SwiftUI.Image(name, bundle: bundle))
                    .resizable()
            } else if let systemName = image.placeholder?.systemName {
                ImageResourceView(url: url, placeholder: SwiftUI.Image(systemName: systemName))
                    .resizable()
            } else {
                ImageResourceView(url: url, placeholder: failure())
                    .resizable()
            }
        } else if let name = image.name {
            ImageResourceView(named: name, in: bundle, placeholder: failure)?
                .resizable()
        } else if let systemName = image.systemName {
            ImageResourceView(systemName: systemName, placeholder: failure)?
                .resizable()
        } else {
            failure()
        }
    }

    @ViewBuilder
    private func Video(_ video: Media.Video) -> some View {
        if let url = video.url {
            VideoPlayer(player: AVPlayer(url: url))
        } else if let resource = video.name, let url = bundle.url(for: resource.fileNameAndExtension) {
            VideoPlayer(player: AVPlayer(url: url))
        } else {
            failure()
        }
    }
}
