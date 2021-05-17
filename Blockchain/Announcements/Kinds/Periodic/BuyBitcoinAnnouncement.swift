// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

/// Buy bitcoin announcement
final class BuyBitcoinAnnouncement: PeriodicAnnouncement & ActionableAnnouncement {

    // MARK: - Internal Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.BuyBitcoin.ctaButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.markDismissed()
                self.action()
                self.dismiss()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            image: AnnouncementCardViewModel.Image(name: "card-icon-cart"),
            title: LocalizationConstants.AnnouncementCards.BuyBitcoin.title,
            description: LocalizationConstants.AnnouncementCards.BuyBitcoin.description,
            buttons: [button],
            dismissState: .dismissible { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.dismissAnalyticsEvent)
                self.markDismissed()
                self.dismiss()
            },
            didAppear: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.didAppearAnalyticsEvent)
            }
        )
    }

    var shouldShow: Bool {
        guard isEnabled else {
            return false
        }
        return !isDismissed
    }

    let type = AnnouncementType.buyBitcoin
    let analyticsRecorder: AnalyticsEventRecording
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    let action: CardAnnouncementAction
    let appearanceRules: PeriodicAnnouncementAppearanceRules

    // MARK: - Private Properties

    private let isEnabled: Bool
    private let disposeBag = DisposeBag()
    // MARK: - Setup

    init(isEnabled: Bool,
         cacheSuite: CacheSuite = resolve(),
         reappearanceTimeInterval: TimeInterval,
         analyticsRecorder: AnalyticsEventRecording = resolve(),
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.isEnabled = isEnabled
        recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        appearanceRules = PeriodicAnnouncementAppearanceRules(recessDurationBetweenDismissals: reappearanceTimeInterval)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}
