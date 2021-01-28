//
//  NewSwapAnnouncement.swift
//  Blockchain
//
//  Created by Paulo on 08/01/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

/// Swap 2.0 announcement is a periodic announcement that introduces the user to in-wallet asset trading
final class NewSwapAnnouncement: OneTimeAnnouncement & ActionableAnnouncement {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.NewSwap

    private enum Style {
        case promo
        case eligible
        case notEligible

        var title: String {
            switch self {
            case .promo:
                return LocalizedString.Promo.title
            case .eligible:
                return LocalizedString.Eligible.title
            case .notEligible:
                return LocalizedString.NotEligible.title
            }
        }

        var description: String {
            switch self {
            case .promo:
                return LocalizedString.Promo.description
            case .eligible:
                return LocalizedString.Eligible.description
            case .notEligible:
                return LocalizedString.NotEligible.description
            }
        }

        var cta: String {
            switch self {
            case .promo:
                return LocalizedString.Promo.ctaButton
            case .eligible:
                return LocalizedString.Eligible.ctaButton
            case .notEligible:
                return LocalizedString.NotEligible.ctaButton
            }
        }
    }

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let style = self.style
        let button = ButtonViewModel.primary(
            with: style.cta
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.action()
                self.dismiss()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            image: AnnouncementCardViewModel.Image(name: "card-icon-swap"),
            title: style.title,
            description: style.description,
            buttons: [button],
            dismissState: .dismissible { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.dismissAnalyticsEvent)
                self.dismiss()
            },
            didAppear: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.didAppearAnalyticsEvent)
            }
        )
    }

    var shouldShow: Bool {
        featureIsEnabled && !isDismissed
    }
    let type: AnnouncementType = .newSwap
    let analyticsRecorder: AnalyticsEventRecording
    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder
    let action: CardAnnouncementAction

    private var featureIsEnabled: Bool {
        // TODO: Remove InternalFeatureFlag before Swap P1 release.
        guard !internalFeatureFlag.isEnabled(.oldSwap) else {
            return false
        }
        return featureConfiguring.configuration(for: .newSwapEnabled).isEnabled
    }
    private var style: Style {
        guard isTier1Or2Verified else {
            return .promo
        }
        return isEligibleForSimpleBuy ? .eligible : .notEligible
    }
    private let isEligibleForSimpleBuy: Bool
    private let isTier1Or2Verified: Bool
    private let featureConfiguring: FeatureConfiguring
    private let disposeBag = DisposeBag()
    private let internalFeatureFlag: InternalFeatureFlagServiceAPI

    // MARK: - Setup

    init(isEligibleForSimpleBuy: Bool,
         isTier1Or2Verified: Bool,
         featureConfiguring: FeatureConfiguring = resolve(),
         internalFeatureFlag: InternalFeatureFlagServiceAPI = resolve(),
         cacheSuite: CacheSuite = resolve(),
         analyticsRecorder: AnalyticsEventRecording = resolve(),
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         dismiss: @escaping CardAnnouncementAction,
         action: @escaping CardAnnouncementAction) {
        self.isEligibleForSimpleBuy = isEligibleForSimpleBuy
        self.isTier1Or2Verified = isTier1Or2Verified
        self.featureConfiguring = featureConfiguring
        self.internalFeatureFlag = internalFeatureFlag
        recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
    }
}
