// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

/// Card announcement for Wallet-Exchange linking
final class ExchangeLinkingAnnouncement: OneTimeAnnouncement & ActionableAnnouncement {
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.Exchange.ctaButton,
            background: .exchangeAnnouncementButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: AnalyticsEvents.Exchange.exchangeAnnouncementTapped)
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.markRemoved()
                self.action()
                self.dismiss()
            }
            .disposed(by: self.disposeBag)
                    
        return AnnouncementCardViewModel(
            type: type,
            image: AnnouncementCardViewModel.Image(name: "exchange-icon-small"),
            title: LocalizationConstants.AnnouncementCards.Exchange.title,
            description: LocalizationConstants.AnnouncementCards.Exchange.description,
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
        guard shouldShowExchangeAnnouncement else {
            return false
        }
        return !isDismissed
    }
    
    let type = AnnouncementType.exchangeLinking
    let analyticsRecorder: AnalyticsEventRecording
    
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction
    
    private let disposeBag = DisposeBag()

    private let shouldShowExchangeAnnouncement: Bool
    
    // MARK: - Setup
    
    init(shouldShowExchangeAnnouncement: Bool,
         cacheSuite: CacheSuite = resolve(),
         analyticsRecorder: AnalyticsEventRecording = resolve(),
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.shouldShowExchangeAnnouncement = shouldShowExchangeAnnouncement
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}
