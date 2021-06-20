// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

struct InternalFeatureItem: Equatable {
    let type: InternalFeature
    let enabled: Bool

    var title: String {
        switch type {
        case .secureChannel:
            return "Secure Channel"
        case .tradingAccountReceive:
            return "Trading Account Receive"
        case .withdrawAndDepositACH:
            return "Withdraw and Deposit - US ACH"
        case .newOnboarding:
            return "New Pin/Onboarding (experimental)"
        case .requestConsoleLogging:
            return "Enable Network Request Console Logs"
        case .showOnboardingAfterSignUp:
            return "Show Onboarding after creating Wallet"
        case .showEmailVerificationInOnboarding:
            return "Show Email Verification in Onboarding Flow"
        case .showEmailVerificationInBuyFlow:
            return "Show Email Verification in Buy Flow"
        }
    }
}

enum InternalFeatureAction {
    case load([InternalFeatureItem])
    case selected(InternalFeatureItem)
}

final class InternalFeatureFlagViewModel {

    let action = PublishRelay<InternalFeatureAction>()

    let items: Driver<[InternalFeatureItem]>

    init(internalFeatureFlagService: InternalFeatureFlagServiceAPI = resolve()) {

        let initialItems = InternalFeature.allCases.map { featureType -> InternalFeatureItem in
            InternalFeatureItem(type: featureType, enabled: internalFeatureFlagService.isEnabled(featureType))
        }

        items = action
            .startWith(.load(initialItems))
            .scan(into: [InternalFeatureItem](), accumulator: { (current, action) in
                switch action {
                case .load(let items):
                    current = items
                case .selected(let item):
                    guard let index = current.firstIndex(of: item) else { return }
                    if item.enabled {
                        internalFeatureFlagService.disable(item.type)
                    } else {
                        internalFeatureFlagService.enable(item.type)
                    }
                    current[index] = InternalFeatureItem(type: item.type, enabled: !item.enabled)
                }
            })
            .asDriver(onErrorJustReturn: [])
    }
}
