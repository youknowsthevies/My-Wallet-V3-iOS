// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Lottie
import SwiftUI

public struct LottieContainerView: View, UIViewRepresentable {

    /// The same as those defined in `Lottie` but prevents
    /// exposing a `Lottie` API.
    public enum LoopMode {
        /// Animation is played once then stops.
        case playOnce
        /// Animation will loop from beginning to end until stopped.
        case loop
        /// Animation will play forward, then backwards and loop until stopped.
        case autoReverse
        /// Animation will loop from beginning to end up to defined amount of times.
        case `repeat`(Float)
        /// Animation will play forward, then backwards a defined amount of times.
        case repeatBackwards(Float)

        var lottieLoopMode: LottieLoopMode {
            switch self {
            case .playOnce:
                return .playOnce
            case .loop:
                return .loop
            case .autoReverse:
                return .autoReverse
            case .repeat(let count):
                return .repeat(count)
            case .repeatBackwards(let count):
                return .repeatBackwards(count)
            }
        }
    }

    private let name: String
    private let loopMode: LoopMode
    private let animationView = AnimationView()

    public init(name: String, loopMode: LoopMode = .playOnce) {
        self.name = name
        self.loopMode = loopMode
    }

    public func makeUIView(context: UIViewRepresentableContext<LottieContainerView>) -> UIView {
        let view = UIView(frame: .zero)

        animationView.animation = Animation.named(name, bundle: Bundle.module)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode.lottieLoopMode
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }

    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieContainerView>) {
        // NOOP
    }
}
