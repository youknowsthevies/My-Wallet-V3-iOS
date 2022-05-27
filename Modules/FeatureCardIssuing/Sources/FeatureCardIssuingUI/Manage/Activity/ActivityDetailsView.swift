// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SwiftUI

struct ActivityDetailsView: View {

    let localized = LocalizationConstants.CardIssuing.Manage.Activity.self
    let store: Store<CardManagementState, CardManagementAction>

    var body: some View {
        WithViewStore(store.scope(state: \.displayedTransaction)) { viewStore in
            VStack(spacing: 0) {
                header
                content(viewStore.state)
            }
        }
    }

    @ViewBuilder func content(_ transaction: CardTransaction?) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if let transaction = transaction {
                    transactionAmount(transaction)
                    PrimaryRow(
                        title: localized.DetailSections.merchant,
                        subtitle: transaction.merchantName,
                        trailing: EmptyView.init,
                        action: {}
                    )
                    PrimaryDivider()
                    PrimaryRow(
                        title: localized.DetailSections.dateTime,
                        subtitle: transaction.displayDateTime,
                        trailing: EmptyView.init,
                        action: {}
                    )
                    PrimaryDivider()
                    PrimaryRow(
                        title: localized.DetailSections.paymentMethod,
                        subtitle: "",
                        trailing: EmptyView.init,
                        action: {}
                    )
                    PrimaryDivider()
                    CardTransactionStatusRow(transaction: transaction)
                    PrimaryDivider()
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

    @ViewBuilder func transactionAmount(_ transaction: CardTransaction) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.displayAmount)
                    .typography(.title2)
                    .padding(.horizontal, Spacing.padding3)
                    .padding(.vertical, Spacing.padding2)
                Text(localized.transactionDetails)
                    .typography(.paragraph2)
                    .padding(.horizontal, Spacing.padding3)
                PrimaryDivider()
            }
        }
    }

    @ViewBuilder var header: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                HStack {
                    Text(LocalizationConstants.CardIssuing.Navigation.title)
                        .typography(.title3)
                        .padding([.top], Spacing.padding1)
                    Spacer()
                    Icon.closeCirclev2
                        .frame(width: 24, height: 24)
                        .onTapGesture(perform: {
                            viewStore.send(.closeDetails)
                        })
                }
            }
            .padding([.trailing, .leading], Spacing.padding3)
        }
    }
}

public struct CardTransactionStatusRow: View {

    private let localized = LocalizationConstants.CardIssuing.Manage.Activity.self
    private let transaction: CardTransaction

    public init(
        transaction: CardTransaction
    ) {
        self.transaction = transaction
    }

    public var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(localized.status)
                        .typography(.body2)
                        .foregroundColor(.semantic.title)

                    Text(transaction.displayStatus)
                        .typography(.paragraph1)
                        .foregroundColor(
                            transaction.statusColor
                        )
                }
            }
            .padding(.vertical, Spacing.padding2)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Spacing.padding3)
    }
}

#if DEBUG

struct ActivityDetails_Previews: PreviewProvider {

    static var previews: some View {
        Rectangle()
            .bottomSheet(isPresented: .constant(true)) {
                ActivityDetailsView(
                    store: Store(
                        initialState: .preview,
                        reducer: cardManagementReducer,
                        environment: .preview
                    )
                )
            }
    }
}

#endif
