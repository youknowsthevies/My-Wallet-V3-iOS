//
//  LinkedCardViewModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 3/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import PlatformKit
import PlatformUIKit

final class LinkedCardViewModel {
    
    // MARK: - Types
    
    struct Theme {
        let cardName: String
        let cardNameFont: UIFont
        let cardNameContentColor: UIColor
        let limit: String
        let limitFont: UIFont
        let limitContentColor: UIColor
        
        init(cardName: String,
             cardNameFont: UIFont = .mainSemibold(16.0),
             cardNameContentColor: UIColor = .textFieldText,
             limit: String,
             limitFont: UIFont = .mainMedium(14.0),
             limitContentColor: UIColor = .descriptionText) {
            self.cardName = cardName
            self.cardNameFont = cardNameFont
            self.cardNameContentColor = cardNameContentColor
            self.limit = limit
            self.limitFont = limitFont
            self.limitContentColor = limitContentColor
        }
    }
    
    struct Content {
        let nameContent: LabelContent
        let limitContent: LabelContent
        let limitText: String
        let nameText: String
        
        init(theme: Theme) {
            limitText = theme.limit
            nameText = theme.cardName
            nameContent = .init(text: theme.cardName,
                                font: theme.cardNameFont,
                                color: theme.cardNameContentColor,
                                alignment: .left,
                                accessibility: .none)
            limitContent = .init(text: theme.limit,
                                 font: theme.limitFont,
                                 color: theme.limitContentColor,
                                 alignment: .left,
                                 accessibility: .none)
        }
    }
    
    // MARK: - Properties
    
    /// The theme of the view
    var content: Content {
        set {
            nameTextRelay.accept(newValue.nameText)
            nameContentRelay.accept(newValue.nameContent)
            limitTextRelay.accept(newValue.limitText)
            limitContentRelay.accept(newValue.limitContent)
        }
        get {
            return Content(theme: Theme(
                cardName: nameTextRelay.value,
                limit: limitTextRelay.value)
            )
        }
    }
    
    var nameContent: Driver<LabelContent> {
        nameContentRelay.asDriver()
    }
    
    var limitContent: Driver<LabelContent> {
        limitContentRelay.asDriver()
    }
    
    let badgeImageViewModel: BadgeImageViewModel
    
    // MARK: - Private
    
    private let nameContentRelay = BehaviorRelay<LabelContent>(value: .empty)
    private let limitContentRelay = BehaviorRelay<LabelContent>(value: .empty)
    private let nameTextRelay = BehaviorRelay<String>(value: "")
    private let limitTextRelay = BehaviorRelay<String>(value: "")
    
    init(imageName: String) {
        self.badgeImageViewModel = .default(with: imageName)
    }
}

extension LinkedCardViewModel {
    static func visa(cardName: String, limit: FiatValue) -> LinkedCardViewModel {
        let viewModel = LinkedCardViewModel(imageName: "Visa")
        viewModel.content = Content(theme:
            .init(cardName: cardName,
                  limit: limit.toDisplayString(includeSymbol: true))
        )
        return viewModel
    }
    
    static func mastercard(cardName: String, limit: FiatValue) -> LinkedCardViewModel {
        let viewModel = LinkedCardViewModel(imageName: "Mastercard")
        viewModel.content = Content(theme:
            .init(cardName: cardName,
                  limit: limit.toDisplayString(includeSymbol: true))
        )
        return viewModel
    }
}
