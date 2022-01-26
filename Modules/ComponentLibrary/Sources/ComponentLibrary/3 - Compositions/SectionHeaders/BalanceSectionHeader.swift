// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// BalanceSectionHeader from the Figma Component Library.
///
/// # Figma
///
///  [Section Header](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A11327)
public struct BalanceSectionHeader<Trailing: View>: View {

    private let title: String
    private let subtitle: String
    private let trailing: Trailing

    /// Initialize a Balance Section Header
    /// - Parameters:
    ///   - title: Title of the header
    ///   - subtitle: Subtitle of the header
    ///   - trailing: Generic view displayed trailing in the header.
    public init(
        title: String,
        subtitle: String,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
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
            Spacer()
            trailing
                .frame(maxHeight: 28)
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
                subtitle: "0.1393819 BTC"
            ) {
                IconButton(icon: .favorite) {}
            }
            .previewLayout(.sizeThatFits)

            BalanceSectionHeader(
                title: "$12,293.21",
                subtitle: "0.1393819 BTC"
            ) {
                IconButton(icon: .favorite) {}
            }
            .previewLayout(.sizeThatFits)
            .colorScheme(.dark)
        }
        .frame(width: 375)
    }
}
