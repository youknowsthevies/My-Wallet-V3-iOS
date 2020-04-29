//
//  RemoveCardScreenPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/9/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import PlatformUIKit

final class RemoveCardScreenPresenter {
    
    // MARK: - Types
    
    typealias AccessibilityIDs = Accessibility.Identifier.Settings.RemoveCard
    typealias LocalizationString = LocalizationConstants.Settings.Cards
    
    // MARK: - Public Properties
    
    let badgeImageViewModel: BadgeImageViewModel
    let titleLabelContent: LabelContent
    let descriptionLabelContent: LabelContent
    let removeButtonViewModel: ButtonViewModel
    
    let dismissalRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties
    
    private let interactor: RemoveCardScreenInteractor
    private let disposeBag = DisposeBag()
    
    init(cardData: CardData,
         service: CardDeletionServiceAPI,
         cardListService: CardListServiceAPI,
         loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared) {
        interactor = RemoveCardScreenInteractor(
            service: service,
            cardListService: cardListService
        )
        interactor.contentRelay.accept(cardData.identifier)
        
        interactor
            .state
            .map { $0.isExecuting }
            .bind(onNext: { value in
                switch value {
                case true:
                    loadingViewPresenter.show(with: .circle, text: nil)
                case false:
                    loadingViewPresenter.hide()
                }
            })
            .disposed(by: disposeBag)
        
        interactor
            .state
            .filter { $0 == .complete }
            .mapToVoid()
            .bind(to: dismissalRelay)
            .disposed(by: disposeBag)
        
        titleLabelContent = .init(
            text: cardData.type.name,
            font: .main(.semibold, 20),
            color: .titleText,
            alignment: .center,
            accessibility: .id(AccessibilityIDs.cardNameLabel)
        )
        
        descriptionLabelContent = .init(
            text: "••••" + " \(cardData.number.suffix(4))",
            font: .main(.medium, 14),
            color: .descriptionText,
            alignment: .center,
            accessibility: .id(AccessibilityIDs.cardPrefixLabel)
        )
        
        badgeImageViewModel = .default(
            with: cardData.type.thumbnail ?? "",
            accessibilityIdSuffix: AccessibilityIDs.removeCardButton
        )
        
        removeButtonViewModel = .destructive(with: LocalizationString.removeCard)
        removeButtonViewModel.tapRelay
            .bind(to: interactor.triggerRelay)
            .disposed(by: disposeBag)
    }
}
