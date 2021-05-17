// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation
import PlatformKit
import PlatformUIKit
import ToolKit

final class SwapWalletIntroductionEvent: CompletableWalletIntroductionEvent {

    private static let location: WalletIntroductionLocation = .init(
        screen: .dashboard,
        position: .swap
    )

    var type: WalletIntroductionEventType {
        let location = SwapWalletIntroductionEvent.location
        let viewModel = WalletIntroductionPulseViewModel(
            location: location,
            action: { [weak self] in
                self?.introductionEntry.updateLatestLocation(location)
                self?.selection()
            })
        return .pulse(viewModel)
    }

    let selection: WalletIntroductionAction

    let introductionRecorder: WalletIntroductionRecorder

    var introductionEntry: WalletIntroductionRecorder.Entry {
        introductionRecorder[UserDefaults.Keys.walletIntroLatestLocation.rawValue]
    }

    var shouldShow: Bool {
        guard let location = introductionEntry.value else { return true }
        return SwapWalletIntroductionEvent.location > location
    }

    init(introductionRecorder: WalletIntroductionRecorder = WalletIntroductionRecorder(),
         selection: @escaping WalletIntroductionAction) {
        self.introductionRecorder = introductionRecorder
        self.selection = selection
    }
}

final class SwapDescriptionIntroductionEvent: WalletIntroductionEvent, WalletIntroductionAnalyticsEvent {

    var type: WalletIntroductionEventType {
        let viewModel = IntroductionSheetViewModel(
            title: LocalizationConstants.Onboarding.IntroductionSheet.Swap.title,
            description: LocalizationConstants.Onboarding.IntroductionSheet.Swap.description,
            buttonTitle: buttonTitle,
            thumbnail: #imageLiteral(resourceName: "Icon-Swap"),
            onSelection: { [weak self] in
                self?.selection()
            })
        return .sheet(viewModel)
    }

    let selection: WalletIntroductionAction

    var eventType: AnalyticsEvents.WalletIntro {
        .walletIntroSwapViewed
    }

    var shouldShow: Bool {
        true
    }

    private var buttonTitle: String {
        LocalizationConstants.Onboarding.IntroductionSheet.next
    }

    init(selection: @escaping WalletIntroductionAction) {
        self.selection = selection
    }
}
