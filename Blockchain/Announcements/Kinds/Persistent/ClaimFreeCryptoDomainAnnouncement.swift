// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformUIKit
import RxSwift
import ToolKit

final class ClaimFreeCryptoDomainAnnouncement: PersistentAnnouncement, ActionableAnnouncement {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.ClaimFreeDomain

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizedString.button,
            background: .primaryButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(
                    event: AnalyticsEvents.Announcement.cardActioned(type: .claimFreeCryptoDomain)
                )
                self.action()
            }
            .disposed(by: disposeBag)
        return AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: .local(name: "card-icon-unstoppable", bundle: .main),
                contentColor: nil,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: .edge(40)
            ),
            title: LocalizedString.title,
            description: LocalizedString.description,
            buttons: [button],
            dismissState: .dismissible { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(
                    event: AnalyticsEvents.Announcement.cardDismissed(type: .claimFreeCryptoDomain)
                )
                self.dismiss()
            },
            didAppear: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(
                    event: AnalyticsEvents.Announcement.cardShown(type: .claimFreeCryptoDomain)
                )
            }
        )
    }

    var shouldShow: Bool {
        claimFreeDomainEnabled.value
    }

    let type = AnnouncementType.claimFreeCryptoDomain
    let featureFlagsService: FeatureFlagsServiceAPI
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let action: CardAnnouncementAction
    let dismiss: CardAnnouncementAction

    private var claimFreeDomainEnabled: Atomic<Bool> = .init(false)

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        action: @escaping CardAnnouncementAction,
        dismiss: @escaping CardAnnouncementAction
    ) {
        self.featureFlagsService = featureFlagsService
        self.analyticsRecorder = analyticsRecorder
        self.action = action
        self.dismiss = dismiss
        featureFlagsService
            .isEnabled(.local(.blockchainDomains))
            .asSingle()
            .subscribe { [weak self] enabled in
                self?.claimFreeDomainEnabled.mutate { $0 = enabled }
            }
            .disposed(by: disposeBag)
    }
}
