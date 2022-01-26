// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture

private typealias AnalyticsEvent = AnalyticsEvents.New.OnboardingChecklist

extension Reducer where State == OnboardingChecklist.State,
    Action == OnboardingChecklist.Action,
    Environment == OnboardingChecklist.Environment
{

    func analytics() -> Reducer<State, Action, Environment> {
        combined(
            with: Reducer { state, action, environment in
                switch action {
                case .didSelectItem(let item, let selectionSource):
                    let completedItems = state.completedItems
                    return .fireAndForget {
                        if let peeksheetItem = AnalyticsEvent.PeeksheetItem(item: item) {
                            environment.analyticsRecorder.record(
                                event: AnalyticsEvent.peeksheetSelectionClicked(
                                    buttonClicked: selectionSource == .callToActionButton,
                                    currentStepCompleted: completedItems.count,
                                    item: peeksheetItem
                                )
                            )
                        }
                    }

                case .dismissFullScreenChecklist:
                    let completedItems = state.completedItems
                    return .fireAndForget {
                        environment.analyticsRecorder.record(
                            event: AnalyticsEvent.peeksheetDismissed(currentStepCompleted: completedItems.count)
                        )
                    }

                case .presentFullScreenChecklist:
                    let completedItems = state.completedItems
                    return .merge(
                        .fireAndForget {
                            environment.analyticsRecorder.record(
                                event: AnalyticsEvent.peeksheetViewed(currentStepCompleted: completedItems.count)
                            )
                        },
                        .fireAndForget {
                            environment.analyticsRecorder.record(
                                event: AnalyticsEvent.peeksheetProcessClicked(
                                    currentStepCompleted: completedItems.count
                                )
                            )
                        }
                    )

                default:
                    return .none
                }
            }
        )
    }
}
