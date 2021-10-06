// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureInterestDomain
import Localization
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit
import UIComponentsKit

struct InterestAccountListItem: View {

    private typealias LocalizationId = LocalizationConstants.Interest.Screen.Overview

    let store: Store<InterestAccountDetails, InterestAccountListItemAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ActionableView(
                content: {
                    VStack(alignment: .leading, spacing: 12.0) {
                        HStack {
                            badgeImageViewWithViewModel(viewStore.badgeImageViewModel)
                                .frame(width: 32, height: 32)
                            Text(viewStore.currency.name)
                                .textStyle(.title)
                                .foregroundColor(.textTitle)
                        }
                        HStack {
                            Image.CircleIcon.infoIcon
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14.0, height: 14.0)
                            Text(
                                String(
                                    format: LocalizationId.earnUpTo,
                                    "\(viewStore.rate.string(with: 1))%",
                                    viewStore.currency.code
                                )
                            )
                            .textStyle(.body)
                            .foregroundColor(.textSubheading)
                        }
                    }
                    Spacer(minLength: 12.0)
                    Divider()
                        .background(Color.dividerLine)
                    Spacer(minLength: 12.0)
                    HStack {
                        VStack(alignment: .leading, spacing: 4.0) {
                            Text("\(viewStore.currency.code) \(LocalizationId.balance)")
                                .textStyle(.body)
                                .foregroundColor(.textSubheading)
                            Text(viewStore.balance.displayString)
                                .textStyle(.heading)
                                .foregroundColor(.textTitle)
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 4.0) {
                            Text(LocalizationId.totalEarned)
                                .textStyle(.body)
                                .foregroundColor(.textSubheading)
                            Text(viewStore.interestEarned.displayString)
                                .textStyle(.heading)
                                .foregroundColor(.textTitle)
                        }
                    }
                    Spacer(minLength: 12.0)
                    if !viewStore.isEligible {
                        HStack {
                            Image.CircleIcon.infoIcon
                                .renderingMode(.template)
                                .foregroundColor(.badgeTextWarning)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14.0, height: 14.0)
                            Text(viewStore.ineligibilityReason.displayString)
                                .fixedSize()
                                .textStyle(.heading)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.lightContentBackground)
                        )
                        .frame(maxWidth: .infinity)
                    }
                },
                buttons: viewStore.actions.map { action in
                    .init(
                        title: viewStore.actionDisplayString,
                        action: {
                            viewStore.send(action)
                        },
                        enabled: viewStore.isEligible
                    )
                }
            )
        }
    }

    private func badgeImageViewWithViewModel(_ viewModel: BadgeImageViewModel) -> AnyView {
        AnyView(
            BadgeImageViewRepresentable(
                viewModel: viewModel,
                size: 32
            )
        )
    }
}
