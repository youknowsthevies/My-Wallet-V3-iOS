// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

protocol InterestIdentityVerificationAnnouncementRouting: AnyObject {
    func showInterestDashboardAnnouncementScreen(isKYCVerfied: Bool)
}

/// Interest announcement for announcing Interest Account feature + KYC
final class InterestIdentityVerificationAnnouncement: OneTimeAnnouncement & ActionableAnnouncement {

    private typealias LocalizationId = LocalizationConstants.AnnouncementCards.InterestIdentityVerification

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
                image: .local(name: "icon_interest", bundle: .platformUIKit),
                contentColor: .white,
                backgroundColor: .defaultBadge,
                cornerRadius: .round,
                size: .init(edge: 32.0)
            ),
            image: .hidden,
            title: LocalizationId.title,
            description: isKYCVerified ? LocalizationId.Description.kycd : LocalizationId.Description.notKYCd,
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
        !isDismissed
    }

    let type = AnnouncementType.interestFunds
    let analyticsRecorder: AnalyticsEventRecorderAPI

    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction

    private let disposeBag = DisposeBag()

    private let isKYCVerified: Bool

    // MARK: - Setup

    init(isKYCVerified: Bool,
         cacheSuite: CacheSuite = resolve(),
         analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.isKYCVerified = isKYCVerified
        self.recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}
