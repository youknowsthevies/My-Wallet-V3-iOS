// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

protocol CashIdentityVerificationAnnouncementRouting: class {
    func showCashIdentityVerificationScreen()
}

/// Card announcement for announcing Cash feature + KYC
final class CashIdentityVerificationAnnouncement: OneTimeAnnouncement & ActionableAnnouncement {

    private typealias LocalizationId = LocalizationConstants.AnnouncementCards.CashIdentityVerification

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationId.learnMore,
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
            badgeImage: .init(
                imageName: "icon-gbp",
                contentColor: .white,
                backgroundColor: .fiat,
                cornerRadius: .value(4.0),
                size: .init(edge: 32.0)
            ),
            image: .hidden,
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
        guard shouldShowCashIdentityAnnouncement else {
            return false
        }
        return !isDismissed
    }

    let type = AnnouncementType.fiatFundsNoKYC
    let analyticsRecorder: AnalyticsEventRecording

    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction

    private let disposeBag = DisposeBag()

    private let shouldShowCashIdentityAnnouncement: Bool

    // MARK: - Setup

    init(shouldShowCashIdentityAnnouncement: Bool,
         cacheSuite: CacheSuite = resolve(),
         analyticsRecorder: AnalyticsEventRecording = resolve(),
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.shouldShowCashIdentityAnnouncement = shouldShowCashIdentityAnnouncement
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}
