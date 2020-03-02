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
import ToolKit
import PlatformUIKit

/// A presenter for buy intro screen.
final class BuyIntroScreenPresenter {
    
    // MARK: - Types
    
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.IntroScreen
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.IntroScreen

    // MARK: - Properties

    /// The screen title
    let title = LocalizedString.title
        
    /// The view models of the cards
    let viewModels: [AnnouncementCardViewModel]
    
    /// The count of the cells (synchronized with the count of the view models)
    var cellCount: Int {
        viewModels.count
    }
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    private unowned let stateService: SimpleBuyStateServiceAPI
    private let errorRecorder: ErrorRecording

    // MARK: - Setup
    
    init(stateService: SimpleBuyStateServiceAPI,
         errorRecorder: ErrorRecording = CrashlyticsRecorder()) {
        
        // Property setup
        
        self.stateService = stateService
        self.errorRecorder = errorRecorder
        
        // Card setup
        
        let imageSize = CGSize(width: 48, height: 48)
        let background = AnnouncementCardViewModel.Background(color: .background)
        let border = AnnouncementCardViewModel.Border.roundCorners(10)
        
        let buyButton = ButtonViewModel.primary(
            with: LocalizedString.BuyCard.button
        )
        
        let buyCardViewModel = AnnouncementCardViewModel(
            contentAlignment: .center,
            background: background,
            border: border,
            image: .init(name: "card-icon-simple-buy", size: imageSize),
            title: LocalizedString.BuyCard.title,
            description: LocalizedString.BuyCard.description,
            buttons: [buyButton],
            recorder: errorRecorder,
            dismissState: .undismissible
        )
        
        let skipButton = ButtonViewModel.secondary(
            with: LocalizedString.SkipCard.button,
            background: .secondaryButton,
            contentColor: .white,
            borderColor: .clear
        )
        
        let skipCardViewModel = AnnouncementCardViewModel(
            contentAlignment: .center,
            background: background,
            border: border,
            image: .init(name: "card-icon-qr", size: imageSize),
            title: LocalizedString.SkipCard.title,
            description: LocalizedString.SkipCard.description,
            buttons: [skipButton],
            recorder: errorRecorder,
            dismissState: .undismissible
        )
        viewModels = [buyCardViewModel, skipCardViewModel]
                        
        buyButton.tapRelay
            .bind(to: stateService.nextRelay)
            .disposed(by: disposeBag)
        
        skipButton.tapRelay
            .bind(to: stateService.previousRelay)
            .disposed(by: disposeBag)
    }
    
    /// MARK: - Exposed
    
    func navigationBarLeadingButtonTapped() {
        stateService.previousRelay.accept(())
    }
}
