// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public struct IndeterminateProgressViewStyle: ProgressViewStyle {

    @State private var angle: Angle = .degrees(-90)

    private let railColor: Color
    private let trackColor: Color

    public init(railColor: Color, trackColor: Color) {
        self.railColor = railColor
        self.trackColor = trackColor
    }

    public func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            let lineWidth: CGFloat = geometry.size.width / 6.0
            ZStack {
                let style = StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .butt
                )
                Circle()
                    .stroke(trackColor, style: style)
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(railColor, style: style)
                    .rotationEffect(angle)
                    .onAppear {
                        // Dispatch in order to fix a bug where being a child of `NavigationView`
                        // causes the animation to affect things other than the angle.
                        DispatchQueue.main.async {
                            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                                angle = .degrees(angle.degrees + 360)
                            }
                        }
                    }
            }
            .padding(lineWidth / 2)
        }
        .scaledToFit()
    }
}

struct IndeterminateProgressView_Previews: PreviewProvider {

    static var previews: some View {
        ProgressView()
            .progressViewStyle(
                .indeterminate
            )
            .frame(width: 70, height: 70)
    }
}

extension ProgressViewStyle where Self == IndeterminateProgressViewStyle {

    public static var indeterminate: IndeterminateProgressViewStyle {
        .init(
            railColor: Color.semantic.primary,
            trackColor: Color.semantic.blueBG
        )
    }
}
