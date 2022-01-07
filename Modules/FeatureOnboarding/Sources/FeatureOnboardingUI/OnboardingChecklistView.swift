// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

struct OnboardingChecklistView: View {

    private let store: Store<OnboardingChecklist.State, OnboardingChecklist.Action>
    @ObservedObject private var viewStore: ViewStore<OnboardingChecklist.State, OnboardingChecklist.Action>

    init(store: Store<OnboardingChecklist.State, OnboardingChecklist.Action>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        ModalContainer(
            title: LocalizationConstants.Onboarding.Checklist.screenTitle,
            subtitle: LocalizationConstants.Onboarding.Checklist.screenSubtitle,
            onClose: viewStore.send(.dismissFullScreenChecklist),
            topAccessory: {
                VStack(spacing: Spacing.padding2) {
                    CountedProgressView(
                        completedItemsCount: viewStore.completedItems.count,
                        totalItemsCount: viewStore.items.count
                    )

                    Text(LocalizationConstants.Onboarding.Checklist.listTitle)
                        .typography(.micro)
                        .foregroundColor(.semantic.body)
                }
            },
            content: {
                let firstIncompleteItem = viewStore.items.first {
                    !viewStore.completedItems.contains($0)
                }
                VStack(spacing: Spacing.padding3) {
                    VStack(alignment: .leading, spacing: Spacing.baseline) {
                        ForEach(viewStore.items) { item in
                            let completed = viewStore
                                .completedItems
                                .contains(item)
                            OnboardingRow(
                                item: item,
                                completed: completed
                            )
                            .onTapGesture {
                                if !completed {
                                    viewStore.send(.didSelectItem(item.id))
                                }
                            }
                        }
                    }
                    // add extra padding for required spacing
                    .padding(.top, Spacing.padding1)

                    Spacer()

                    if let item = firstIncompleteItem {
                        Button(item.title) {
                            viewStore.send(.didSelectItem(item.id))
                        }
                        .buttonStyle(
                            OnboardingChecklistButtonStyle(item: item)
                        )
                    }
                }
                .padding(.bottom, Spacing.padding3)
                .padding(.horizontal, Spacing.padding3)
            }
        )
    }
}

struct OnboardingRow: View {

    let item: OnboardingChecklist.Item
    let completed: Bool

    var body: some View {
        HStack(spacing: Spacing.padding2) {
            Icon.identification
                .accentColor(item.accentColor)
                .background(
                    RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                        .fill(item.backgroundColor)
                )
                .frame(width: 32, height: 32)
                .clipped()

            VStack(alignment: .leading, spacing: Spacing.textSpacing) {
                Text(item.detail)
                    .typography(.caption1)
                    .foregroundColor(.semantic.body)

                Text(item.title)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            }

            Spacer()

            if completed {
                Icon.checkCircle
                    .frame(width: 24, height: 24)
                    .accentColor(.semantic.success)
            } else {
                Icon.chevronRight
                    .frame(width: 24, height: 24)
                    .accentColor(item.accentColor)
            }
        }
        .padding(Spacing.padding2)
        .background(
            RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                .fill(Color.semantic.background)
                .shadow(
                    color: .black.opacity(0.12),
                    radius: 2,
                    x: 1,
                    y: 1
                )
        )
    }
}

struct OnboardingChecklistButtonStyle: ButtonStyle {

    let item: OnboardingChecklist.Item

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration
                .label
                .typography(.body2)
        }
        .accentColor(.white)
        .foregroundColor(.white)
        .padding(.vertical, Spacing.padding1)
        .padding(.horizontal, Spacing.padding2)
        .frame(maxWidth: .infinity, minHeight: 48)
        .background(
            RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                .fill(configuration.isPressed ? item.backgroundColor : item.accentColor)
        )
        .contentShape(Rectangle())
    }
}

struct OnboardingChecklistView_Previews: PreviewProvider {

    static var previews: some View {
        OnboardingChecklistView(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: OnboardingChecklist.Environment(
                    userState: .just(
                        UserState(
                            hasCompletedKYC: false,
                            hasLinkedPaymentMethods: false,
                            hasEverPurchasedCrypto: false
                        )
                    ),
                    presentBuyFlow: { _ in },
                    presentKYCFlow: { _ in },
                    presentPaymentMethodLinkingFlow: { _ in }
                )
            )
        )

        OnboardingChecklistView(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: OnboardingChecklist.Environment(
                    userState: .just(
                        UserState(
                            hasCompletedKYC: true,
                            hasLinkedPaymentMethods: false,
                            hasEverPurchasedCrypto: false
                        )
                    ),
                    presentBuyFlow: { _ in },
                    presentKYCFlow: { _ in },
                    presentPaymentMethodLinkingFlow: { _ in }
                )
            )
        )

        OnboardingChecklistView(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: OnboardingChecklist.Environment(
                    userState: .just(
                        UserState(
                            hasCompletedKYC: true,
                            hasLinkedPaymentMethods: true,
                            hasEverPurchasedCrypto: false
                        )
                    ),
                    presentBuyFlow: { _ in },
                    presentKYCFlow: { _ in },
                    presentPaymentMethodLinkingFlow: { _ in }
                )
            )
        )

        OnboardingChecklistView(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: OnboardingChecklist.Environment(
                    userState: .just(
                        UserState(
                            hasCompletedKYC: true,
                            hasLinkedPaymentMethods: true,
                            hasEverPurchasedCrypto: true
                        )
                    ),
                    presentBuyFlow: { _ in },
                    presentKYCFlow: { _ in },
                    presentPaymentMethodLinkingFlow: { _ in }
                )
            )
        )
    }
}
