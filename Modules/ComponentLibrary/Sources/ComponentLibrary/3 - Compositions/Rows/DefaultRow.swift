// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// DefaultRow from the Figma Component Library.
///
///
/// # Usage:
///
/// Only title and subtitle are mandatory to create a Row. Rest of parameters are optional. When no trailing accessory view es provided, a chevron view is shown
/// ```
/// DefaultRow(
///     title: "Link a Bank",
///     subtitle: "Instant Connection",
///     description: "Securely link a bank to buy crypto, deposit cash and withdraw back to your bank at anytime.",
///     tags: [
///         Tag(text: "Fastest", variant: .success),
///         Tag(text: "Warning Alert", variant: .warning)
///     ] {
///         Switch()
///     }
///
/// ```
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Table Rows](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A11163)
public struct DefaultRow<AccessoryView: View>: View {

    private let title: String
    private let subtitle: String?
    private let description: String?
    private let tags: [Tag]
    private let accessoryView: AccessoryView

    /// Create a default row with the given data.
    ///
    /// Only Title is mandatory, rest of the parameters are optional and the row will form itself depending on the given data
    /// - Parameters:
    ///   - title: Title of the row
    ///   - subtitle: Optional subtitle on the main vertical content view
    ///   - description: Optional description text on the main vertical content view
    ///   - tags: Optional array of tags object. They show up on the bottom part of the main vertical content view, and align themself horizontally
    ///   - accessoryView: Optional view on the trailing part of the row. If no view is provided, a chevron icon is added automatically.
    public init(
        title: String,
        subtitle: String? = nil,
        description: String? = nil,
        tags: [Tag] = [],
        @ViewBuilder accessoryView: () -> AccessoryView
    ) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.tags = tags
        self.accessoryView = accessoryView()
    }

    public var body: some View {
        HStack(alignment: .customRowVerticalAlignment, spacing: 0) {
            Row.mainContentView(
                title: title,
                subtitle: subtitle,
                description: description,
                tags: tags
            )
            Spacer()
            accessoryView
                .padding(.horizontal, Spacing.padding1)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.padding2)
        .background(Color.semantic.background)
    }
}

extension DefaultRow where AccessoryView == AnyView {

    public init(
        title: String,
        subtitle: String? = nil,
        description: String? = nil,
        tags: [Tag] = []
    ) {
        self.init(title: title, subtitle: subtitle, description: description, tags: tags) { AnyView(Row.chevron) }
    }
}

enum Row {

    @ViewBuilder static func mainContentView(
        title: String,
        subtitle: String? = nil,
        description: String? = nil,
        tags: [Tag]
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .typography(.paragraph1)
                        .foregroundColor(
                            Color(
                                light: .palette.grey600,
                                dark: .palette.dark200
                            )
                        )
                }
            }
            .alignmentGuide(.customRowVerticalAlignment) {
                $0[VerticalAlignment.center]
            }
            if let description = description {
                Spacer()
                    .frame(height: 20)
                Text(description)
                    .typography(.caption1)
                    .foregroundColor(
                        Color(
                            light: .palette.grey600,
                            dark: .palette.dark200
                        )
                    )
            }
            if !tags.isEmpty {
                Spacer()
                    .frame(height: 16)
                HStack {
                    ForEach(0..<tags.count) { index in
                        tags[index]
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.padding1)
    }

    @ViewBuilder static var chevron: some View {
        Icon.chevronRight
            .fixedSize()
            .accentColor(
                Color(
                    light: .palette.grey400,
                    dark: .palette.grey400
                )
            )
    }
}

extension VerticalAlignment {
    struct CustomRowVerticalAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center]
        }
    }

    static let customRowVerticalAlignment = VerticalAlignment(CustomRowVerticalAlignment.self)
}

// swiftlint:disable line_length
struct DefaultRow_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            DefaultRow(
                title: "Trading",
                subtitle: "Buy & Sell"
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Default Row")

            DefaultRow(
                title: "Email Address",
                subtitle: "satoshi@blockchain.com",
                tags: [Tag(text: "Confirmed", variant: .success)]
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Row with Tag")

            DefaultRow(
                title: "From: BTC Trading Account",
                subtitle: "To: 0x093871209487120934812027675"
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Default Row")

            DefaultRow(
                title: "Link a Bank",
                subtitle: "Instant Connection",
                description: "Securely link a bank to buy crypto, deposit cash and withdraw back to your bank at anytime.",
                tags: [
                    Tag(text: "Fastest", variant: .success),
                    Tag(text: "Warning Alert", variant: .warning)
                ]
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Large Row")

            DefaultRow(
                title: "Cloud Backup",
                subtitle: "Buy & Sell"
            ) {
                Switch()
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Toggle Row")

            DefaultRow(title: "Features and Limits")
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Just title Row")
        }
        .frame(width: 375)
    }

    struct Switch: View {
        @State var isOn: Bool = false

        var body: some View {
            PrimarySwitch(
                variant: .green,
                accessibilityLabel: "Test",
                isOn: $isOn
            )
        }
    }
}
