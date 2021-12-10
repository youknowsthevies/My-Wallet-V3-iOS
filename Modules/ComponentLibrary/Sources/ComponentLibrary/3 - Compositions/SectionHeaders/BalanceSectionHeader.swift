// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// BalanceSectionHeader from the Figma Component Library.
///
/// # Figma
///
///  [Section Header](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A11327)
public struct BalanceSectionHeader: View {

    private let title: String
    private let subtitle: String
    private let buttonTitle: String
    private let buttonAction: () -> Void

    /// Initialize a Balance Section Header
    /// - Parameters:
    ///   - title: Title of the header
    ///   - subtitle: Subtitle of the header
    ///   - buttonTitle: Title that appears on the button of the header
    ///   - buttonAction: Action to apply on button tap
    public init(
        title: String,
        subtitle: String,
        buttonTitle: String,
        buttonAction: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .typography(.title3)
                    .foregroundColor(.semantic.title)
                Text(subtitle)
                    .typography(.paragraph2)
                    .foregroundColor(
                        Color(
                            light: .palette.grey600,
                            dark: .palette.dark200
                        )
                    )
            }
            .frame(maxWidth: .infinity)
            Spacer()
                .frame(maxWidth: .infinity)
            PrimaryButton(title: buttonTitle, action: buttonAction)
        }
        .padding(24)
        .background(Color.semantic.background)
        .listRowInsets(EdgeInsets())
    }
}

struct BalanceSectionHeader_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            BalanceSectionHeader(
                title: "$12,293.21",
                subtitle: "0.1393819 BTC",
                buttonTitle: "Buy BTC"
            ) {}
                .previewLayout(.sizeThatFits)

            BalanceSectionHeader(
                title: "$12,293.21",
                subtitle: "0.1393819 BTC",
                buttonTitle: "Buy BTC"
            ) {}
                .previewLayout(.sizeThatFits)
                .colorScheme(.dark)
        }
        .frame(width: 375)
    }
}
