// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension View {

    @ViewBuilder
    public func inscribed<Content>(
        _ content: @autoclosure @escaping () -> Content
    ) -> some View where Content: View {
        inscribed(content)
    }

    @ViewBuilder
    public func inscribed<Content>(
        @ViewBuilder _ content: @escaping () -> Content
    ) -> some View where Content: View {
        inscribed(aspectRatio: 1, content)
    }

    @ViewBuilder
    public func inscribed<Content>(
        aspectRatio: CGFloat,
        _ content: @autoclosure @escaping () -> Content
    ) -> some View where Content: View {
        inscribed(aspectRatio: aspectRatio, content)
    }

    @ViewBuilder
    public func inscribed<Content>(
        aspectRatio: CGFloat,
        @ViewBuilder _ content: @escaping () -> Content
    ) -> some View where Content: View {
        ZStack {
            if aspectRatio.isNormal {
                withGeometry(\.size) { view, size in
                    let theta = atan2(aspectRatio, 1)
                    let size = CGSize(
                        width: sin(theta) * size.width,
                        height: cos(theta) * size.height
                    )
                    view.overlay(
                        content()
                            .frame(width: size.width, height: size.height),
                        alignment: .center
                    )
                }
            } else {
                self
            }
        }
    }
}

struct Inscribed_Previews: PreviewProvider {

    static var previews: some View {
        Circle()
            .frame(width: 100, height: 100)
            .foregroundColor(Color.red.opacity(0.15))
            .inscribed(Text("Hello World!"))
    }
}
