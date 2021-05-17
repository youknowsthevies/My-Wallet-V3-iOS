// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation
import PlatformKit
import PlatformUIKit
import ToolKit

final class HomeWalletIntroductionEvent: CompletableWalletIntroductionEvent {

    var type: WalletIntroductionEventType {
        let location: WalletIntroductionLocation = .init(
            screen: .dashboard,
            position: .home
        )

        let viewModel = WalletIntroductionPulseViewModel(
            location: location,
            action: {
                self.introductionEntry.updateLatestLocation(location)
                self.selection()
        })
        return .pulse(viewModel)
    }

    let selection: WalletIntroductionAction

    let introductionRecorder: WalletIntroductionRecorder

    var introductionEntry: WalletIntroductionRecorder.Entry {
        introductionRecorder[UserDefaults.Keys.walletIntroLatestLocation.rawValue]
    }

    var shouldShow: Bool {
        guard introductionEntry.value != nil else { return true }
        return false
    }

    init(introductionRecorder: WalletIntroductionRecorder = WalletIntroductionRecorder(),
         selection: @escaping WalletIntroductionAction) {
        self.introductionRecorder = introductionRecorder
        self.selection = selection
    }
}

final class HomeDescriptionWalletIntroductionEvent: WalletIntroductionEvent, WalletIntroductionAnalyticsEvent {

    var type: WalletIntroductionEventType {

        let viewModel = IntroductionSheetViewModel(
            title: LocalizationConstants.Onboarding.IntroductionSheet.Home.title,
            description: LocalizationConstants.Onboarding.IntroductionSheet.Home.description,
            buttonTitle: LocalizationConstants.Onboarding.IntroductionSheet.next,
            thumbnail: #imageLiteral(resourceName: "Icon-Home"),
            onSelection: {
                self.selection()
            }
        )

        return .sheet(viewModel)
    }

    let selection: WalletIntroductionAction

    var eventType: AnalyticsEvents.WalletIntro {
        .walletIntroPortfolioViewed
    }

    var shouldShow: Bool {
        true
    }

    init(selection: @escaping WalletIntroductionAction) {
        self.selection = selection
    }
}
