// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import SwiftUI
import ToolKit

struct ProductDetailsView: View {

    private let localizedStrings = LocalizationConstants.CardIssuing.Order.Details.self

    private let close: () -> Void

    init(close: @escaping () -> Void) {
        self.close = close
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                header
                Section(header: SectionHeader(title: localizedStrings.Benefits.title)) {
                    VStack(spacing: 0) {
                        Row(
                            title: localizedStrings.Benefits.rewards,
                            trailing: {
                                Text("1%")
                                    .typography(.paragraph2)
                                    .foregroundColor(.WalletSemantic.title)
                            }
                        )
                    }
                }
                Section(header: SectionHeader(title: localizedStrings.Fees.title)) {
                    VStack(spacing: 0) {
                        Row(
                            title: localizedStrings.Fees.annual,
                            trailing: { noChargeLabel }
                        )
                        PrimaryDivider()
                        Row(title: localizedStrings.Fees.delivery, trailing: {
                            noChargeLabel
                        })
                    }
                }
                Section(header: SectionHeader(title: localizedStrings.Card.title)) {
                    VStack(spacing: 0) {
                        Row(
                            title: localizedStrings.Card.contactless,
                            trailing: {
                                Text(LocalizationConstants.yes)
                                    .typography(.paragraph2)
                                    .foregroundColor(.WalletSemantic.title)
                            }
                        )
                        PrimaryDivider()
                        TitleRow(
                            title: localizedStrings.Card.consumerFinancialProtectionBureau
                        )
                        PrimaryDivider()
                        Row(
                            title: localizedStrings.Card.shortFormDisclosure,
                            trailing: { chevronRight }
                        )
                        PrimaryDivider()
                        TitleRow(
                            title: localizedStrings.Card.blockchainTermsAndConditions
                        )
                        PrimaryDivider()
                        Row(
                            title: localizedStrings.Card.termsAndConditions,
                            trailing: { chevronRight }
                        )
                    }
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.semantic.background.ignoresSafeArea())
        }
    }

    struct Row<Trailing: View>: View {
        let title: String
        let trailing: () -> Trailing
        let action: (() -> Void)?

        init(
            title: String,
            trailing: @escaping () -> Trailing,
            action: (() -> Void)? = nil
        ) {
            self.title = title
            self.trailing = trailing
            self.action = action
        }

        var body: some View {
            if let action = action {
                Button(action: action) {
                    content
                }
            } else {
                content
            }
        }

        @ViewBuilder var content: some View {
            HStack(alignment: .center, spacing: 0) {
                Text(title)
                    .typography(.paragraph2)
                    .foregroundColor(.WalletSemantic.title)
                Spacer()
                trailing()
            }
            .padding(.vertical, Spacing.padding2)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.padding3)
        }
    }

    struct TitleRow: View {
        let title: String

        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                Text(title)
                    .typography(.paragraph2)
                    .foregroundColor(.WalletSemantic.overlay)
                    .padding(.leading, Spacing.padding2)
                Spacer()
            }
            .padding(.vertical, Spacing.padding2)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.padding3)
        }
    }

    @ViewBuilder var header: some View {
        VStack {
            HStack {
                Text(localizedStrings.Navigation.title)
                    .typography(.title3)
                    .padding([.top, .leading], Spacing.padding1)
                Spacer()
                Icon.closeCirclev2
                    .frame(width: 24, height: 24)
                    .onTapGesture(perform: { close() })
            }
            .padding(Spacing.padding2)
            Image("card-selection", bundle: .cardIssuing)
                .resizable()
                .frame(width: 243, height: 154)
            Text(LocalizationConstants.CardIssuing.CardType.Virtual.title)
                .typography(.title2)
                .multilineTextAlignment(.center)
                .padding(.bottom, Spacing.padding3)
        }
    }

    @ViewBuilder var noChargeLabel: some View {
        Text(localizedStrings.Fees.noCharge)
            .typography(.paragraph2)
            .foregroundColor(.WalletSemantic.success)
    }

    @ViewBuilder var chevronRight: some View {
        Icon.chevronRight
            .frame(width: 18, height: 18)
            .accentColor(
                .WalletSemantic.overlay
            )
            .flipsForRightToLeftLayoutDirection(true)
    }
}

extension ProductDetailsView.Row where Trailing == EmptyView {
    init(
        title: String,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        trailing = {
            EmptyView()
        }
        self.action = action
    }
}

#if DEBUG
struct ProductDetails_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProductDetailsView(
                close: {}
            )
        }
    }
}
#endif
