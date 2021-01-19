//
//  SwapAnnouncement.swift
//  Blockchain
//
//  Created by Daniel Huri on 18/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

/// Swap announcement is a periodic announcement that introduces the user to in-wallet asset trading
final class SwapAnnouncement: PeriodicAnnouncement & ActionableAnnouncement {
    
    // MARK: - Properties
    
    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.Swap.ctaButton
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
            image: AnnouncementCardViewModel.Image(name: "card-icon-swap"),
            title: LocalizationConstants.AnnouncementCards.Swap.title,
            description: LocalizationConstants.AnnouncementCards.Swap.description,
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
        guard featureIsEnabled else {
            return false
        }
        guard !hasTrades else {
            return false
        }
        return !isDismissed
    }
    
    let type = AnnouncementType.swap
    let analyticsRecorder: AnalyticsEventRecording
    
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction
    
    let appearanceRules: PeriodicAnnouncementAppearanceRules

    private var featureIsEnabled: Bool {
        !featureConfiguring.configuration(for: .newSwapEnabled).isEnabled
    }
    private let hasTrades: Bool
    private let disposeBag = DisposeBag()
    private let featureConfiguring: FeatureConfiguring
    // MARK: - Setup
    
    init(hasTrades: Bool,
         cacheSuite: CacheSuite = resolve(),
         reappearanceTimeInterval: TimeInterval,
         analyticsRecorder: AnalyticsEventRecording = resolve(),
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         featureConfiguring: FeatureConfiguring = resolve(),
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.hasTrades = hasTrades
        self.featureConfiguring = featureConfiguring
        recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        appearanceRules = PeriodicAnnouncementAppearanceRules(recessDurationBetweenDismissals: reappearanceTimeInterval)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}
