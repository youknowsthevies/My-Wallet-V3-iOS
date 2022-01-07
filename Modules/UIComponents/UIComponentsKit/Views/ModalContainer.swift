// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if canImport(SharedComponentLibrary)
import SharedComponentLibrary
typealias IconButtonFromComponentLibrary = SharedComponentLibrary.IconButton
#else
import ComponentLibrary
typealias IconButtonFromComponentLibrary = ComponentLibrary.IconButton
#endif
import SwiftUI

public struct ModalContainer<TopAccessory: View, Content: View>: View {

    public enum HeaderStyle {
        case small
        case medium
        case large
    }

    private let title: String?
    private let subtitle: String?
    private let headerStyle: HeaderStyle
    private let closeAction: () -> Void
    @ViewBuilder private let topAccessory: () -> TopAccessory
    @ViewBuilder private let content: () -> Content

    public init(
        title: String?,
        subtitle: String?,
        headerStyle: HeaderStyle = .large,
        onClose closeAction: @autoclosure @escaping () -> Void,
        @ViewBuilder topAccessory: @escaping () -> TopAccessory,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.headerStyle = headerStyle
        self.closeAction = closeAction
        self.topAccessory = topAccessory
        self.content = content
    }

    public var body: some View {
        VStack(spacing: Spacing.padding3) {
            header()
                .padding(.horizontal, Spacing.padding3)

            content()
                .frame(maxWidth: .infinity)
        }
        .background(Color.semantic.background)
    }

    @ViewBuilder
    private func header() -> some View {
        switch headerStyle {
        case .small:
            smallHeader
        case .medium:
            mediumHeader
        case .large:
            largeHeader
        }
    }

    private var smallHeader: some View {
        VStack(spacing: Spacing.padding1) {
            closeHandle
            HStack(alignment: .top, spacing: Spacing.padding2) {
                VStack(alignment: .leading, spacing: Spacing.baseline) {
                    if let title = title {
                        Text(title)
                            .typography(.title3)
                    }

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .typography(.paragraph1)
                    }
                }
                .padding(.top, 12) // pad to half the close button

                Spacer()

                closeButton
            }
        }
    }

    private var mediumHeader: some View {
        VStack(spacing: Spacing.padding2) {
            VStack(spacing: Spacing.padding1) {
                closeHandle

                HStack(alignment: .top) {
                    Spacer()
                    closeButton
                }
            }

            topAccessory()

            if title != nil || subtitle != nil {
                VStack(spacing: Spacing.baseline) {
                    if let title = title {
                        Text(title)
                            .typography(.title3)
                    }

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .typography(.paragraph1)
                    }
                }
            }
        }
        .multilineTextAlignment(.center)
    }

    private var largeHeader: some View {
        VStack(spacing: Spacing.padding2) {
            VStack(spacing: Spacing.padding1) {
                closeHandle

                HStack(alignment: .top) {
                    Spacer()
                    closeButton
                }
            }

            topAccessory()

            if title != nil || subtitle != nil {
                VStack(spacing: Spacing.baseline) {
                    if let title = title {
                        Text(title)
                            .typography(.title2)
                    }

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .typography(.paragraph1)
                    }
                }
            }
        }
        .multilineTextAlignment(.center)
    }

    private var closeHandle: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.semantic.medium)
            .frame(width: 32, height: 4)
            .padding(.top, Spacing.padding2)
            .padding(.bottom, Spacing.padding1)
            .onTapGesture(perform: closeAction)
    }

    private var closeButton: some View {
        IconButtonFromComponentLibrary(
            icon: .closev2.circle(),
            action: closeAction
        )
        .frame(width: 24, height: 24)
    }
}

extension ModalContainer where TopAccessory == EmptyView {

    public init(
        onClose closeAction: @autoclosure @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            title: nil,
            subtitle: nil,
            onClose: closeAction(),
            topAccessory: EmptyView.init,
            content: content
        )
    }

    public init(
        title: String,
        onClose closeAction: @autoclosure @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            title: title,
            subtitle: nil,
            headerStyle: .small,
            onClose: closeAction(),
            topAccessory: EmptyView.init,
            content: content
        )
    }

    public init(
        title: String,
        subtitle: String,
        headerStyle: HeaderStyle = .large,
        onClose closeAction: @autoclosure @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            headerStyle: headerStyle,
            onClose: closeAction(),
            topAccessory: EmptyView.init,
            content: content
        )
    }
}

struct ModalContainer_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            ModalContainer(
                onClose: print("Close")
            ) {
                Color.red
            }

            ModalContainer(
                title: "My Modal",
                onClose: print("Close")
            ) {
                Color.red
            }

            ModalContainer(
                title: "My Modal",
                subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                onClose: print("Close")
            ) {
                Color.red
            }

            ModalContainer(
                title: "My Modal",
                subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                headerStyle: .small,
                onClose: print("Close")
            ) {
                Color.red
            }

            ModalContainer(
                title: "My Modal",
                subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                onClose: print("Close"),
                topAccessory: {
                    Icon.blockchain
                        .frame(width: 32, height: 32)
                },
                content: {
                    Color.red
                }
            )
        }
    }
}
