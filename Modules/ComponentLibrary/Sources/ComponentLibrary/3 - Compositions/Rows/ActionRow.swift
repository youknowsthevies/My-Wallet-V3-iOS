// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// ActionRow from the Figma Component Library.
///
///
/// # Usage:
///
/// Title, subtitle and leading image are mandatory to create a Row. Rest of parameters are optional. A chevron view is shown as accesory view
/// ```
/// ActionRow(
///     title: "Link a Bank",
///     subtitle: "Instant Connection",
///     description: "Securely link a bank to buy crypto, deposit cash and withdraw back to your bank at anytime.",
///     tags: [
///         Tag(text: "Fastest", variant: .success),
///         Tag(text: "Warning Alert", variant: .warning)
///     ] {
///         Icon.bank
///             .fixedSize()
///     }
///
/// ```
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Table Rows](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A11163)

public struct ActionRow<LeadingView: View>: View {

    private let title: String
    private let subtitle: String?
    private let description: String?
    private let tags: [Tag]
    private let leadingView: LeadingView

    /// Create an action row with the given data.
    ///
    /// Only Title is mandatory, rest of the parameters are optional and the row will form itself depending on the given data
    /// - Parameters:
    ///   - title: Title of the row
    ///   - subtitle: Optional subtitle on the main vertical content view
    ///   - description: Optional description text on the main vertical content view
    ///   - tags: Optional array of tags object. They show up on the bottom part of the main vertical content view, and align themself horizontally
    ///   - leadingView: View on the leading part of the row.
    public init(
        title: String,
        subtitle: String? = nil,
        description: String? = nil,
        tags: [Tag] = [],
        @ViewBuilder leadingView: () -> LeadingView
    ) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.tags = tags
        self.leadingView = leadingView()
    }

    public var body: some View {
        HStack(alignment: .customRowVerticalAlignment, spacing: 0) {
            leadingView
                .padding(.horizontal, Spacing.padding1)
            Row.mainContentView(
                title: title,
                subtitle: subtitle,
                description: description,
                tags: tags
            )
            Spacer()
            Row.chevron
                .padding(.horizontal, Spacing.padding1)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.padding2)
        .background(Color.semantic.background)
    }
}

// swiftlint:disable line_length
struct ActionRow_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            ActionRow(
                title: "Back Up Your Wallet",
                subtitle: "Step 1"
            ) {
                Icon.wallet
                    .fixedSize()
                    .accentColor(.semantic.dark)
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Action Row")

            ActionRow(
                title: "Gold Level",
                subtitle: "Higher Trading Limits",
                tags: [Tag(text: "Approved", variant: .success)]
            ) {
                Icon.apple
                    .fixedSize()
                    .accentColor(.semantic.orangeBG)
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Row with Tag")

            ActionRow(
                title: "Trade",
                subtitle: "BTC -> ETH"
            ) {
                Icon.trade
                    .fixedSize()
                    .accentColor(.semantic.success)
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Action Row")

            ActionRow(
                title: "Link a Bank",
                subtitle: "Instant Connection",
                description: "Securely link a bank to buy crypto, deposit cash and withdraw back to your bank at anytime.",
                tags: [
                    Tag(text: "Fastest", variant: .success),
                    Tag(text: "Warning Alert", variant: .warning)
                ]
            ) {
                Icon.bank
                    .fixedSize()
                    .accentColor(.semantic.primary)
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Large Row")

            ActionRow(title: "Features and Limits") {
                Icon.blockchain
                    .fixedSize()
                    .accentColor(.semantic.primary)
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Just title Row")
        }
        .frame(width: 375)
    }
}
