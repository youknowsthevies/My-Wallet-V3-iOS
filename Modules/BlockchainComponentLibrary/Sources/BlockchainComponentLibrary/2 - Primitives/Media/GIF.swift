// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI
import SwiftyGif
import WebKit

public struct GIF {

    private class Object: ObservableObject {
        var manager: SwiftyGifManager
        init(manager: SwiftyGifManager = .defaultManager) {
            self.manager = manager
        }
    }

    @Environment(\.levelOfIntegrity) private var levelOfIntegrity: Float

    private let data: Data
    private let loop: Int

    @StateObject private var cache = Object()

    public init(data: Data, loop: Int) {
        self.data = data
        self.loop = loop
    }
}

extension GIF: OptionalDataInit {

    public init?(_ data: Data?) {
        guard let data = data else { return nil }
        self.data = data
        loop = -1
    }
}

#if canImport(AppKit)
extension GIF: NSViewRepresentable {

    public class Container: NSView {
        let imageView: NSImageView
        public init(imageView: NSImageView) {
            self.imageView = imageView
            super.init(frame: .zero)
        }

        @available(*, unavailable)
        public required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override public func viewDidMoveToSuperview() {
            super.viewDidMoveToSuperview()
            imageView.imageScaling = .scaleProportionallyDown
            imageView.translatesAutoresizingMaskIntoConstraints = false
            if imageView.superview !== self {
                addSubview(imageView)
            }
        }

        override public func layout() {
            super.layout()
            imageView.frame = bounds
        }
    }

    public func makeNSView(context: Context) -> Container {
        let imageView: NSImageView
        do {
            let image = try NSImage(gifData: data, levelOfIntegrity: levelOfIntegrity)
            imageView = NSImageView(gifImage: image, manager: cache.manager, loopCount: loop)
        } catch {
            imageView = NSImageView()
        }
        return Container(imageView: imageView)
    }

    public func updateNSView(_ container: Container, context: Context) {
        container.imageView.startAnimatingGif()
    }
}
#endif

#if canImport(UIKit)
extension GIF: UIViewRepresentable {

    public class Container: UIView {
        let imageView: UIImageView
        public init(imageView: UIImageView) {
            self.imageView = imageView
            super.init(frame: .zero)
        }

        @available(*, unavailable)
        public required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override public func didMoveToSuperview() {
            super.didMoveToSuperview()
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            if imageView.superview !== self {
                addSubview(imageView)
                NSLayoutConstraint.activate(
                    [
                        imageView.heightAnchor.constraint(equalTo: heightAnchor),
                        imageView.widthAnchor.constraint(equalTo: widthAnchor)
                    ]
                )
            }
        }
    }

    public func makeUIView(context: Context) -> Container {
        let imageView: UIImageView
        do {
            imageView = try UIImageView(
                gifImage: UIImage(gifData: data, levelOfIntegrity: levelOfIntegrity),
                manager: cache.manager,
                loopCount: loop
            )
        } catch {
            imageView = UIImageView()
        }
        return Container(imageView: imageView)
    }

    public func updateUIView(_ container: Container, context: Context) {
        container.imageView.startAnimatingGif()
    }
}
#endif

private struct GIFLevelOfIntegrityKey: EnvironmentKey {
    static let defaultValue = Float.default
}

extension EnvironmentValues {
    public var levelOfIntegrity: Float {
        get { self[GIFLevelOfIntegrityKey.self] }
        set { self[GIFLevelOfIntegrityKey.self] = newValue }
    }
}

extension View {
    @warn_unqualified_access public func levelOfIntegrity(_ value: Float) -> some View {
        environment(\.levelOfIntegrity, value)
    }
}
