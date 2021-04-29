//
//  SimpleBuyFinishSignupAnnouncement.swift
//  Blockchain
//
//  Created by Paulo on 30/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

final class SimpleBuyFinishSignupAnnouncement: PersistentAnnouncement & ActionableAnnouncement {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.SimpleBuyFinishSignup

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizedString.ctaButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.action()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            image: AnnouncementCardViewModel.Image(name: "card-icon-v"),
            title: LocalizedString.title,
            description: LocalizedString.description,
            buttons: [button],
            dismissState: .undismissible,
            didAppear: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.didAppearAnalyticsEvent)
            }
        )
    }

    var shouldShow: Bool {
        hasIncompleteBuyFlow && canCompleteTier2
    }

    let type = AnnouncementType.simpleBuyPendingTransaction
    let analyticsRecorder: AnalyticsEventRecording

    let action: CardAnnouncementAction

    private let hasIncompleteBuyFlow: Bool
    private let canCompleteTier2: Bool

    private let disposeBag = DisposeBag()
    // MARK: - Setup

    init(canCompleteTier2: Bool,
         hasIncompleteBuyFlow: Bool,
         analyticsRecorder: AnalyticsEventRecording = resolve(),
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         action: @escaping CardAnnouncementAction) {
        self.canCompleteTier2 = canCompleteTier2
        self.hasIncompleteBuyFlow = hasIncompleteBuyFlow
        self.action = action
        self.analyticsRecorder = analyticsRecorder
    }
}
