//
//  SimpleBuyFinishSignupAnnouncement.swift
//  Blockchain
//
//  Created by Paulo on 30/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import ToolKit
import PlatformKit
import PlatformUIKit

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
            recorder: errorRecorder,
            dismissState: .undismissible,
            didAppear: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.didAppearAnalyticsEvent)
            }
        )
    }

    var shouldShow: Bool {
        return hasIncompleteBuyFlow && canCompleteTier2
    }

    let type = AnnouncementType.simpleBuyPendingTransaction
    let analyticsRecorder: AnalyticsEventRecording

    let action: CardAnnouncementAction

    private let hasIncompleteBuyFlow: Bool
    private let canCompleteTier2: Bool

    private let disposeBag = DisposeBag()
    private let errorRecorder: ErrorRecording

    // MARK: - Setup

    init(canCompleteTier2: Bool,
         hasIncompleteBuyFlow: Bool,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         action: @escaping CardAnnouncementAction) {
        self.canCompleteTier2 = canCompleteTier2
        self.hasIncompleteBuyFlow = hasIncompleteBuyFlow
        self.errorRecorder = errorRecorder
        self.action = action
        self.analyticsRecorder = analyticsRecorder
    }
}
