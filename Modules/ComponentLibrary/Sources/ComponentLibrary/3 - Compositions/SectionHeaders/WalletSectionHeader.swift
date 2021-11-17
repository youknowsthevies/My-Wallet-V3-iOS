// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// WalletSectionHeader from the Figma Component Library.
///
///
/// # Usage:
///
/// Can be a Section Header inside a List, VStack u other.
/// ```
/// List {
///     Section(header: WalletSectionHeader(title: "Wallets & Accounts"))  {
///         ...
///     }
/// }
/// ```
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Buttons](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A11327)
public struct WalletSectionHeader: View {

    private let title: String

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        HStack {
            Text(title)
                .typography(.caption2)
                .foregroundColor(.semantic.title)
                .padding(.leading, Spacing.padding())
            Spacer()
        }
        .padding(.vertical, Spacing.baseline)
        .background(Color.semantic.light)
        .listRowInsets(
            EdgeInsets(
                top: 0,
                leading: 0,
                bottom: 0,
                trailing: 0
            )
        )
    }
}

struct WalletSectionHeader_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            List {
                Section(header: WalletSectionHeader(title: "Wallets & Accounts")) {
                    Text("first row")
                    Text("second row")
                    Text("third row")
                }
                Section(header: WalletSectionHeader(title: "More Wallets")) {
                    Text("first row")
                    Text("second row")
                    Text("third row")
                }
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Header on List")

            VStack {
                Section(header: WalletSectionHeader(title: "Wallets & Accounts")) {
                    Text("first row")
                    Text("second row")
                    Text("third row")
                }
                Section(header: WalletSectionHeader(title: "More Wallets")) {
                    Text("first row")
                    Text("second row")
                    Text("third row")
                }
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Header on VStack")
        }
    }
}
