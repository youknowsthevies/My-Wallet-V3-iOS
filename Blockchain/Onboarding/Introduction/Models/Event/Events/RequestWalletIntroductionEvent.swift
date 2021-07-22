// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import PlatformKit
import PlatformUIKit
import ToolKit

final class RequestWalletIntroductionEvent: CompletableWalletIntroductionEvent {

    private static let location: WalletIntroductionLocation = .init(
        screen: .dashboard,
        position: .receive
    )

    var type: WalletIntroductionEventType {
        let location = RequestWalletIntroductionEvent.location
        let viewModel = WalletIntroductionPulseViewModel(
            location: location,
            action: {
                self.introductionEntry.updateLatestLocation(location)
                self.selection()
            }
        )
        return .pulse(viewModel)
    }

    let selection: WalletIntroductionAction

    let introductionRecorder: WalletIntroductionRecorder

    var introductionEntry: WalletIntroductionRecorder.Entry {
        introductionRecorder[UserDefaults.Keys.walletIntroLatestLocation.rawValue]
    }

    var shouldShow: Bool {
        guard let location = introductionEntry.value else { return true }
        return RequestWalletIntroductionEvent.location > location
    }

    init(
        introductionRecorder: WalletIntroductionRecorder = WalletIntroductionRecorder(),
        selection: @escaping WalletIntroductionAction
    ) {
        self.introductionRecorder = introductionRecorder
        self.selection = selection
    }
}

final class RequestDescriptionIntroductionEvent: WalletIntroductionEvent, WalletIntroductionAnalyticsEvent {

    var type: WalletIntroductionEventType {
        let viewModel = IntroductionSheetViewModel(
            title: LocalizationConstants.Onboarding.IntroductionSheet.Request.title,
            description: LocalizationConstants.Onboarding.IntroductionSheet.Request.description,
            buttonTitle: LocalizationConstants.Onboarding.IntroductionSheet.next,
            thumbnail: #imageLiteral(resourceName: "Icon-Receive"),
            onSelection: {
                self.selection()
            }
        )
        return .sheet(viewModel)
    }

    let selection: WalletIntroductionAction

    var eventType: AnalyticsEvents.WalletIntro {
        .walletIntroRequestViewed
    }

    var shouldShow: Bool {
        true
    }

    init(selection: @escaping WalletIntroductionAction) {
        self.selection = selection
    }
}
