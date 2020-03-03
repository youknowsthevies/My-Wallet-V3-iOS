//
//  SimpleBuyKYCPendingPresenter.swift
//  Blockchain
//
//  Created by Paulo on 22/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import ToolKit
import PlatformUIKit

final class SimpleBuyKYCPendingPresenter {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.SimpleBuy.KYCScreen
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.KYCScreen
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy

    // MARK: - Properties

    let title = LocalizedString.title

    var titleAccessibility: String {
        return AccessibilityId.titleLabel
    }
    
    var subtitleAccessibility: String {
        return AccessibilityId.subtitleLabel
    }
    
    var buttonAccessibility: String {
        return AccessibilityId.goToWalletButton
    }

    var model: Driver<SimpleBuyKYCPendingViewModel> {
        modelRelay.asDriver()
    }

    private let disposeBag = DisposeBag()
    private let interactor: SimpleBuyKYCPendingInteractor
    private unowned let stateService: RoutingStateEmitterAPI
    private let analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording
    private var modelRelay: BehaviorRelay<SimpleBuyKYCPendingViewModel>!

    init(stateService: RoutingStateEmitterAPI,
         interactor: SimpleBuyKYCPendingInteractor,
         analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording = AnalyticsEventRecorder.shared) {
        self.analyticsRecorder = analyticsRecorder
        self.stateService = stateService
        self.interactor = interactor
        modelRelay = BehaviorRelay(value: model(verificationState: .loading))

        interactor
            .verificationState
            .takeWhile { $0 != .completed }
            .map(weak: self) { (self, state) in
                self.model(verificationState: state)
            }
            .bind(to: modelRelay)
            .disposed(by: disposeBag)
        
        interactor.verificationState
            .map { $0.analyticsEvent }
            .bind(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)

        interactor
            .verificationState
            .filter { $0 == .completed }
            .mapToVoid()
            .bind(to: stateService.nextRelay)
            .disposed(by: disposeBag)

        interactor.startPollingForGoldTier()
    }

    private func model(verificationState: SimpleBuyKYCPendingVerificationState) -> SimpleBuyKYCPendingViewModel {
        func actionButton(title: String) -> ButtonViewModel {
            let button = ButtonViewModel.primary(with: title)
            button.tapRelay
                .bind(to: stateService.previousRelay)
                .disposed(by: disposeBag)
            return button
        }

        switch verificationState {
        case .ineligible:
            return SimpleBuyKYCPendingViewModel(
                asset: .image(.region),
                title: LocalizedString.Ineligible.title,
                subtitle: LocalizedString.Ineligible.subtitle,
                button: actionButton(title: LocalizedString.Ineligible.button)
            )
        case .completed,
             .loading:
            return SimpleBuyKYCPendingViewModel(
                asset: .loading,
                title: LocalizedString.Verifying.title,
                subtitle: LocalizedString.Verifying.subtitle,
                button: actionButton(title: LocalizedString.button)
            )
        case .manualReview:
            return SimpleBuyKYCPendingViewModel(
                asset: .image(.error),
                title: LocalizedString.ManualReview.title,
                subtitle: LocalizedString.ManualReview.subtitle,
                button: actionButton(title: LocalizedString.button)
            )
        case .pending:
            return SimpleBuyKYCPendingViewModel(
                asset: .image(.clock),
                title: LocalizedString.PendingReview.title,
                subtitle: LocalizedString.PendingReview.subtitle,
                button: actionButton(title: LocalizedString.button)
            )
        }
    }
}
