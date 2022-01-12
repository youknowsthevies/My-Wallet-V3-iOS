// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import Localization
import SwiftUI
import ToolKit

public struct OnboardingChecklistOverview: View {

    private let store: Store<OnboardingChecklist.State, OnboardingChecklist.Action>

    public init(store: Store<OnboardingChecklist.State, OnboardingChecklist.Action>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store.stateless) { viewStore in
            HStack(spacing: Spacing.padding2) {
                WithViewStore(store) { viewStore in
                    CountedProgressView(
                        completedItemsCount: viewStore.completedItems.count,
                        totalItemsCount: viewStore.items.count
                    )
                }

                VStack(alignment: .leading, spacing: Spacing.textSpacing) {
                    Text(LocalizationConstants.Onboarding.ChecklistOverview.title)
                        .typography(.caption1)
                        .foregroundColor(.semantic.body)

                    Text(LocalizationConstants.Onboarding.ChecklistOverview.subtitle)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)
                }

                Spacer()

                Icon.chevronRight
                    .frame(width: 24, height: 24)
                    .accentColor(.semantic.primary)
            }
            // pad content
            .padding(Spacing.padding2)
            // round rectable background with border
            .background(
                RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                    .fill(Color.semantic.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                    .stroke(Color.semantic.primary)
            )
            // actions
            .onTapGesture {
                viewStore.send(.presentFullScreenChecklist)
            }
            .onAppear {
                viewStore.send(.startObservingUserState)
            }
            .onDisappear {
                viewStore.send(.stopObservingUserState)
            }
        }
        .navigationRoute(in: store)
    }
}

struct SwiftUIView_Previews: PreviewProvider {

    static var previews: some View {
        OnboardingChecklistOverview(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: OnboardingChecklist.Environment(
                    userState: .empty(),
                    presentBuyFlow: { _ in },
                    presentKYCFlow: { _ in },
                    presentPaymentMethodLinkingFlow: { _ in }
                )
            )
        )
    }
}
