// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

final class ClaimFreeCryptoDomainAnnoucement: PersistentAnnouncement, ActionableAnnouncement {

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
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.markRemoved()
                self.action()
                self.dismiss()
            }
            .disposed(by: disposeBag)
        return AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: .local(name: "card-icon-unstoppable", bundle: .main),
                contentColor: nil,
                backgroundColor: .clear,
                cornerRadius: .none size: .edge(40)
            ),
            title: LocalizedString.title,
            description: LocalizedString.description,
            buttons: [button],
            dismissState: .dismissible { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.dismissAnalyticsEvent)
                self.markRemoved()
                self.dismiss()
            },
            didAppear: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(
                    self.didAppearAnalyticsEvent
                )
            }
        )
    }

    let type = AnnouncementType.claimFreeCryptoDomain
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let action: CardAnnouncementAction
    let dismiss: CardAnnouncementAction

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        action: @escaping CardAnnouncementAction,
        dismiss: @escaping CardAnnouncementAction
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.action = action
        self.dismiss = dismiss
    }
}
