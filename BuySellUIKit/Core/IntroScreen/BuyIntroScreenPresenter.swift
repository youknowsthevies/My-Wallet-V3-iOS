//
//  BuyIntroScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import Localization
import ToolKit
import PlatformUIKit

/// A presenter for buy intro screen.
final class BuyIntroScreenPresenter {
    
    // MARK: - Types
    
    typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.IntroScreen
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.IntroScreen

    // MARK: - Properties

    /// The screen title
    let title = LocalizedString.title
            
    let cardViewModel: AnnouncementCardViewModel
    let themeBackgroundImageViewContent: ImageViewContent
    let continueButtonViewModel: ButtonViewModel
    let skipButtonViewModel: ButtonViewModel
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    private unowned let stateService: StateServiceAPI
    private let recordingProvider: RecordingProviderAPI

    // MARK: - Setup
    
    init(stateService: StateServiceAPI, recordingProvider: RecordingProviderAPI) {
        self.recordingProvider = recordingProvider
        self.stateService = stateService
        
        themeBackgroundImageViewContent = .init(
            imageName: "sb-intro-bg-theme",
            accessibility: .id(AccessibilityId.themeBackgroundImageView)
        )
        
        // Card setup
        
        continueButtonViewModel = ButtonViewModel.primary(
            with: LocalizedString.continueButton
        )
        
        skipButtonViewModel = ButtonViewModel.secondary(
            with: LocalizedString.skipButton
        )
        
        cardViewModel = AnnouncementCardViewModel(
            contentAlignment: .center,
            border: .none,
            image: .init(name: "card-icon-cart", size: .init(edge: 48)),
            title: LocalizedString.BuyCard.title,
            description: LocalizedString.BuyCard.description,
            dismissState: .undismissible
        )
         
        continueButtonViewModel.tapRelay
            .bindAndCatch(to: stateService.nextRelay)
            .disposed(by: disposeBag)
        
        continueButtonViewModel.tapRelay
            .map { AnalyticsEvent.sbWantToBuyButtonClicked }
            .bindAndCatch(to: recordingProvider.analytics.recordRelay)
            .disposed(by: disposeBag)
        
        skipButtonViewModel.tapRelay
            .bindAndCatch(to: stateService.previousRelay)
            .disposed(by: disposeBag)
        
        skipButtonViewModel.tapRelay
            .map { AnalyticsEvent.sbWantToBuyButtonSkip }
            .bindAndCatch(to: recordingProvider.analytics.recordRelay)
            .disposed(by: disposeBag)
        
        recordingProvider.analytics.record(event: AnalyticsEvent.sbWantToBuyScreenShown)
    }
    
    // MARK: - Exposed
    
    func previous() {
        stateService.previousRelay.accept(())
    }
}
