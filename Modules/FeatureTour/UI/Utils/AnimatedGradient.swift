// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SwiftUI

public struct AnimatedGradient: UIViewRepresentable {
    public init() {}

    public func makeUIView(context: Context) -> UIView {
        let wrapperView = UIView()
        let gradient = UIImageView(
            image: UIImage(
                named: "gradient",
                in: Bundle.featureTour,
                with: nil
            )
        )
        wrapperView.addSubview(gradient)
        gradient.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gradient.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor),
            gradient.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor)
        ])
        return wrapperView
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        let gradient = uiView.subviews.first
        let gradientWidth = gradient?.bounds.width ?? 0
        UIView.animate(withDuration: 60) {
            gradient?.transform = CGAffineTransform(translationX: -(gradientWidth - UIScreen.main.bounds.width), y: 0)
        }
    }
}
