// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

/// Card announcement for announcing Cash feature.
/// Should only show if the user has KYC'd and has not
/// linked a bank.
final class FiatFundsLinkBankAnnouncement: OneTimeAnnouncement & ActionableAnnouncement {

    private typealias LocalizationId = LocalizationConstants.AnnouncementCards.FiatFundsLinkBank

    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationId.linkABank,
            background: .primaryButton
        )
        button.tapRelay
            .bindAndCatch(weak: self, onNext: { _ in
                // TODO: Analytics
                self.markRemoved()
                self.action()
                self.dismiss()
            })
            .disposed(by: self.disposeBag)
        return .init(
            type: type,
            badgeImage: .hidden,
            image: .init(name: "icon-bank",
                         tintColor: .secondary,
                         bundle: .platformUIKit),
            title: LocalizationId.title,
            description: LocalizationId.description,
            buttons: [button],
            dismissState: .dismissible { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.dismissAnalyticsEvent)
                self.markRemoved()
                self.dismiss()
            },
            didAppear: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.didAppearAnalyticsEvent)
            }
        )
    }

    var shouldShow: Bool {
        guard shouldShowLinkBankAnnouncement else {
            return false
        }
        return !isDismissed
    }

    let type = AnnouncementType.fiatFundsKYC
    let analyticsRecorder: AnalyticsEventRecording

    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction

    private let disposeBag = DisposeBag()

    private let shouldShowLinkBankAnnouncement: Bool

    // MARK: - Setup
    
    init(shouldShowLinkBankAnnouncement: Bool,
         cacheSuite: CacheSuite = resolve(),
         analyticsRecorder: AnalyticsEventRecording = resolve(),
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.shouldShowLinkBankAnnouncement = shouldShowLinkBankAnnouncement
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}
