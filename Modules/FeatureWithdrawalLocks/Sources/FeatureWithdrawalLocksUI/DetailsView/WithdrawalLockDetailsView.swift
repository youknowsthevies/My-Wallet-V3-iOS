// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import FeatureWithdrawalLocksDomain
import Localization
import SwiftUI

struct WithdrawalLockDetailsView: View {

    let withdrawalLocks: WithdrawalLocks
    let url = URL(
        string: "https://support.blockchain.com/hc/en-us/articles/360051018131-Trading-Account-Withdrawal-Holds"
    )!

    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.openURL) var openURL

    private typealias LocalizationIds = LocalizationConstants.WithdrawalLock

    var body: some View {
        ZStack(alignment: .top) {
            HStack {
                Spacer()
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Icon.closeCircle
                        .accentColor(.semantic.muted)
                        .frame(height: 24.pt)
                }
            }
            .padding([.trailing])

            VStack {
                Text(
                    String(
                        format: LocalizationIds.onHoldAmountTitle,
                        withdrawalLocks.amount
                    )
                )
                .typography(.title3)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding([.top, .leading, .trailing])

                Text(LocalizationIds.holdingPeriodDescription)
                    .typography(.paragraph1)
                    .padding([.leading, .trailing])
                    .padding(.top, 8)
                    .padding(.bottom, 32)

                if withdrawalLocks.items.isEmpty {
                    Spacer()
                    Text(LocalizationIds.noLocks)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.muted)
                        .padding()
                } else {
                    HStack {
                        Text(LocalizationIds.heldUntilTitle.uppercased())
                        Spacer()
                        Text(LocalizationIds.amountTitle.uppercased())
                    }
                    .padding([.leading, .trailing])
                    .foregroundColor(.semantic.muted)
                    .typography(.overline)

                    PrimaryDivider()

                    ForEach(withdrawalLocks.items) { item in
                        WithdrawalLockItemView(item: item)
                    }
                }

                Spacer()

                PrimaryButton(title: LocalizationConstants.WithdrawalLock.learnMoreButtonTitle) {
                    openURL(url)
                }
                .padding()
            }
        }
        .padding(.top, 24.pt)
    }
}

struct WithdrawalLockItemView: View {
    let item: WithdrawalLocks.Item

    var body: some View {
        HStack {
            Text(item.date)
            Spacer()
            Text(item.amount)
        }
        .foregroundColor(.semantic.body)
        .typography(.paragraph2)
        .frame(height: 44)
        .padding([.leading, .trailing])

        PrimaryDivider()
    }
}

// swiftlint:disable type_name
struct WithdrawalLockDetailsView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        WithdrawalLockDetailsView(
            withdrawalLocks: .init(items: [], amount: "$100")
        )
    }
}
