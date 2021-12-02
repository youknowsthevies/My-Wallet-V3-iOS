// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if canImport(SharedComponentLibrary)
import SharedComponentLibrary
#else
import ComponentLibrary
#endif
import SwiftUI

public struct ModalContainer<Content: View>: View {

    private let title: String
    private let subtitle: String?
    private let closeAction: () -> Void
    @ViewBuilder private let content: () -> Content

    public init(
        title: String,
        subtitle: String? = nil,
        onClose closeAction: @autoclosure @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.closeAction = closeAction
        self.content = content
    }

    public var body: some View {
        VStack(spacing: .zero) {
            if subtitle == nil {
                titleOnlyHeader
                    .padding(.top, Spacing.padding3)
            } else {
                closeHandle
                titleAndSubtitleHeader
            }

            content()
                .frame(maxWidth: .infinity)

            Spacer()
        }
        .background(Color.semantic.background)
    }

    private var closeHandle: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.semantic.medium)
            .frame(width: 32, height: 4)
            .padding(.top, Spacing.padding2)
            .padding(.bottom, Spacing.padding1)
            .onTapGesture(perform: closeAction)
    }

    private var titleOnlyHeader: some View {
        HStack(alignment: .top) {
            Text(title)
                .typography(.title3)
                // pad top with the close button size
                .padding([.top], 12)

            Spacer()

            ComponentLibrary.IconButton(
                icon: .closev2.circle(),
                action: closeAction
            )
            .frame(width: 24, height: 24)
        }
        .padding(.bottom, Spacing.padding3)
        .padding(.horizontal, Spacing.padding3)
    }

    private var titleAndSubtitleHeader: some View {
        VStack(spacing: Spacing.padding1) {
            HStack {
                Spacer()
                ComponentLibrary.IconButton(
                    icon: .closev2.circle(),
                    action: closeAction
                )
                .frame(width: 24, height: 24)
            }
            VStack(spacing: Spacing.baseline) {
                Text(title)
                    .typography(.title2)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .typography(.paragraph1)
                }
            }
        }
        .padding(.bottom, Spacing.padding3)
        .padding(.horizontal, Spacing.padding3)
    }
}

struct ModalContainer_Previews: PreviewProvider {
    static var previews: some View {
        ModalContainer(title: "My Modal", onClose: print("Close")) {
            VStack {
                Text("Hello, World!")
            }
        }
    }
}
