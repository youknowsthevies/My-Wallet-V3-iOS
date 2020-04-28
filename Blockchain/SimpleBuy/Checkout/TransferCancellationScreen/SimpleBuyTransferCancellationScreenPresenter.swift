//
//  SimpleBuyTransferCancellationScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 2/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformUIKit
import PlatformKit
import RxRelay
import ToolKit

final class SimpleBuyTransferCancellationScreenPresenter {
    
    // MARK: - Localization
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias AccessibilityIDs = Accessibility.Identifier.SimpleBuy.Cancellation
    private typealias LocalizationIDs = LocalizationConstants.SimpleBuy.TransferDetails.Cancellation
    
    // MARK: - Public Properties
    
    let titleContent: LabelContent
    let descriptionContent: LabelContent
    
    let noButtonViewModel: ButtonViewModel
    let yesButtonViewModel: ButtonViewModel
    
    let dismissalRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties
    
    private let analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording
    private let loadingViewPresenter: LoadingViewPresenting
    private let alertPresenter: AlertViewPresenter
    private let stateService: SimpleBuyStateServiceAPI
    private let interactor: SimpleBuyTransferCancellationInteractor
    private let disposeBag = DisposeBag()
    
    init(stateService: SimpleBuyStateServiceAPI,
         currency: CryptoCurrency,
         alertPresenter: AlertViewPresenter = .shared,
         loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared,
         analyticsRecorder: AnalyticsEventRecording & AnalyticsEventRelayRecording = AnalyticsEventRecorder.shared,
         interactor: SimpleBuyTransferCancellationInteractor) {
        self.analyticsRecorder = analyticsRecorder
        self.interactor = interactor
        self.stateService = stateService
        self.alertPresenter = alertPresenter
        self.loadingViewPresenter = loadingViewPresenter
        
        titleContent = .init(
            text: LocalizationIDs.title,
            font: .mainSemibold(20.0),
            color: .textFieldText,
            alignment: .center,
            accessibility: .id(AccessibilityIDs.titleLabel)
        )
        descriptionContent = .init(
            text: "\(LocalizationIDs.Description.thisWillRemove) \(currency.name) \(LocalizationIDs.Description.buyOrder)",
            font: .mainMedium(14.0),
            color: .textFieldText,
            alignment: .center,
            accessibility: .id(AccessibilityIDs.descriptionLabel)
        )
        
        noButtonViewModel = .cancel(
            with: LocalizationConstants.ObjCStrings.BC_STRING_NO,
            accessibilityId: AccessibilityIDs.noButton
        )
        yesButtonViewModel = .primary(
            with: LocalizationConstants.ObjCStrings.BC_STRING_YES,
            accessibilityId: AccessibilityIDs.yesButton
        )
        
        noButtonViewModel.tapRelay
            .bind(weak: self) { (self) in
                self.analyticsRecorder.record(event: AnalyticsEvent.sbCancelOrderGoBack)
                self.stateService.previousRelay.accept(())
            }
            .disposed(by: disposeBag)
        
        setupCancellationBinding()
    }
    
    private func setupCancellationBinding() {
        let cancellationResult = yesButtonViewModel
            .tapRelay
            .show(loader: loadingViewPresenter, style: .circle)
            .flatMap(weak: self) { (self, _) in
                self.interactor.cancel()
            }
            .mapToResult()
            .hide(loader: loadingViewPresenter)
            .share(replay: 1)

        cancellationResult
            .filter { $0.isSuccess }
            .mapToVoid()
            .bind(weak: self) { (self) in
                self.analyticsRecorder.record(event: AnalyticsEvent.sbCancelOrderConfirmed)
                self.stateService.nextRelay.accept(())
            }
            .disposed(by: disposeBag)

        cancellationResult
            .mapToVoid()
            .bind(to: dismissalRelay)
            .disposed(by: disposeBag)
            
        cancellationResult
            .filter { $0.isFailure }
            .mapToVoid()
            .bind(weak: self) { (self) in
                self.cancellationDidFail()
            }
            .disposed(by: disposeBag)
    }
    
    private func cancellationDidFail() {
        alertPresenter.error()
        analyticsRecorder.record(event: AnalyticsEvent.sbCancelOrderError)
    }
    
    func viewDidLoad() {
        analyticsRecorder.record(event: AnalyticsEvent.sbCancelOrderPrompt)
    }
}
