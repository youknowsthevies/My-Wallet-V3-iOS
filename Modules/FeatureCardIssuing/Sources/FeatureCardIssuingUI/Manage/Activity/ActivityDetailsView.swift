// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SwiftUI

struct ActivityDetailsView: View {

    let localized = LocalizationConstants.CardIssuing.Manage.Activity.self
    let store: Store<Card.Transaction?, CardManagementAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                header
                content(viewStore.state)
            }
        }
    }

    @ViewBuilder func content(_ transaction: Card.Transaction?) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                if let transaction = transaction {
                    transactionAmount(transaction)
                    Group {
                        DetailsRow(
                            leadingTitle: localized.DetailSections.merchant,
                            trailingTitle: transaction.merchantName
                        )
                        PrimaryDivider()
                        DetailsRow(
                            leadingTitle: localized.DetailSections.dateTime,
                            trailingTitle: transaction.displayDate,
                            trailingSubtitle: transaction.displayTime
                        )
                        PrimaryDivider()
                        DetailsRow(
                            leadingTitle: localized.DetailSections.paymentMethod,
                            trailingTitle: transaction.counterAmount?.symbol ??
                                transaction.originalAmount.symbol
                        )
                        PrimaryDivider()
                        DetailsRow(
                            leadingTitle: localized.DetailSections.feesTitle,
                            trailingTitle: transaction.fee.displayString,
                            leadingSubtitle: localized.DetailSections.feesDescription
                        )
                        PrimaryDivider()
                    }
                    if transaction.state == .completed {
                        Group {
                            DetailsRow(
                                leadingTitle: localized.DetailSections.adjustedPaymentTitle,
                                trailingTitle: transaction.clearedFundingAmount.displayString,
                                leadingSubtitle: localized.DetailSections.adjustedPaymentDescription
                            )
                            PrimaryDivider()
                            DetailsRow(
                                leadingSubtitle: .caption(localized.DetailSections.initialAmount),
                                trailingSubtitle: .caption("-" + transaction.fundingAmount.displayString)
                            )
                            PrimaryDivider()
                            DetailsRow(
                                leadingSubtitle: .caption(localized.DetailSections.returnedAmount),
                                trailingSubtitle: .caption("+" + transaction.reversedAmount.displayString)
                            )
                            PrimaryDivider()
                            DetailsRow(
                                leadingSubtitle: .custom(
                                    localized.DetailSections.settledAmount,
                                    .semantic.title,
                                    .caption1
                                ),
                                trailingSubtitle: .custom(
                                    transaction.clearedFundingAmount.displayString,
                                    .semantic.title,
                                    .caption1
                                )
                            )
                            PrimaryDivider()
                        }
                    }
                    Group {
                        DetailsRow(
                            leadingTitle: .title(localized.status),
                            trailingTitle: .custom(
                                transaction.displayStatus,
                                transaction.statusColor,
                                .body2
                            )
                        )
                        PrimaryDivider()
                    }
                }
                WithViewStore(store) { viewStore in
                    SmallMinimalButton(title: localized.Button.help, action: {
                        viewStore.send(.showSupportFlow)
                    })
                    .padding(Spacing.padding2)
                }
            }
        }
        .frame(maxHeight: 60.vh)
    }

    @ViewBuilder func transactionAmount(_ transaction: Card.Transaction) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.originalAmount.displayString)
                    .typography(.title2)
                    .padding(.horizontal, Spacing.padding3)
                    .padding(.vertical, Spacing.padding2)
                Text(localized.transactionDetails)
                    .typography(.paragraph2)
                    .padding(.horizontal, Spacing.padding3)
                    .foregroundColor(.semantic.muted)
                PrimaryDivider()
            }
        }
    }

    @ViewBuilder var header: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                HStack {
                    Text(
                        LocalizationConstants
                            .CardIssuing
                            .Manage
                            .Activity
                            .Navigation
                            .title
                    )
                    .typography(.title3)
                    .padding([.top], Spacing.padding1)
                    Spacer()
                    Icon.closeCirclev2
                        .frame(width: 24, height: 24)
                        .onTapGesture(perform: {
                            viewStore.send(.setTransactionDetailsVisible(false))
                        })
                }
            }
            .padding([.trailing, .leading], Spacing.padding3)
        }
    }
}

#if DEBUG

struct ActivityDetails_Previews: PreviewProvider {

    static var reducer = Reducer<Card.Transaction?, CardManagementAction, CardManagementEnvironment> { _, _, _ in
        .none
    }

    static var previews: some View {
        Rectangle()
            .bottomSheet(isPresented: .constant(true)) {
                ActivityDetailsView(
                    store: Store(
                        initialState: Card.Transaction.success,
                        reducer: ActivityDetails_Previews.reducer,
                        environment: .preview
                    )
                )
            }
    }
}

#endif
