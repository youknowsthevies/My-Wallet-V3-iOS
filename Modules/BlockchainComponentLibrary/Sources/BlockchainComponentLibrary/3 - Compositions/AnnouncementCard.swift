// Copyright © Blockchain Luxembourg S.A. All rights reserved.
import SwiftUI

/// AnnouncementCard from the Figma Component Library.
///
/// # Figma
///
///  [Cards](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A7478)
public struct AnnouncementCard<Leading: View>: View {

    private let title: String
    private let message: String
    private let onCloseTapped: () -> Void
    private let leading: Leading

    /// Initialize a Announcement Card
    /// - Parameters:
    ///   - title: Title of the card
    ///   - message: Message of the card
    ///   - onCloseTapped: Closure executed when the user types the close icon
    ///   - leading: View on the leading of the card.
    public init(
        title: String,
        message: String,
        onCloseTapped: @escaping () -> Void,
        @ViewBuilder leading: () -> Leading
    ) {
        self.title = title
        self.message = message
        self.onCloseTapped = onCloseTapped
        self.leading = leading()
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 16) {
            HStack(spacing: 16) {
                leading
                    .frame(width: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .typography(.caption1)
                        .foregroundColor(.palette.grey100)
                    Text(message)
                        .typography(.body2)
                        .foregroundColor(.palette.white)
                }
            }
            Button(
                action: onCloseTapped,
                label: {
                    Icon.closev2
                        .circle(backgroundColor: .palette.grey800)
                        .accentColor(.palette.grey400)
                        .frame(width: 24)
                }
            )
        }
        .padding(Spacing.padding2)
        .background(
            GeometryReader { proxy in
                Image("PCB Faded", bundle: .componentLibrary)
                    .resizable()
                    .scaledToFit()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .offset(y: -proxy.size.height / 3)
                    .opacity(0.05)
            }
        )
        .clipShape(
            RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
        )
        .background(
            RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
                .fill(
                    Color(
                        light: .palette.grey900,
                        dark: .palette.dark800
                    )
                )
                .shadow(
                    color: .palette.black.opacity(0.04),
                    radius: 1,
                    x: 0,
                    y: 3
                )
                .shadow(
                    color: .palette.black.opacity(0.12),
                    radius: 8,
                    x: 0,
                    y: 3
                )
        )
    }
}

struct AnnouncementCard_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            AnnouncementCard(
                title: "New Asset",
                message: "Dogecoin (DOGE) is now available on Blockchain.",
                onCloseTapped: {},
                leading: {
                    Icon.wallet
                        .accentColor(.semantic.gold)
                }
            )
            .previewLayout(.sizeThatFits)

            AnnouncementCard(
                title: "New Asset",
                message: "Dogecoin (DOGE) is now available on Blockchain.",
                onCloseTapped: {},
                leading: {
                    Icon.wallet
                        .accentColor(.semantic.gold)
                }
            )
            .previewLayout(.sizeThatFits)
            .colorScheme(.dark)
        }
    }
}
