//
//  CardCVVTextFieldViewModel.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 23/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import RxRelay
import RxSwift
import ToolKit

public final class CardCVVTextFieldViewModel: TextFieldViewModel {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(validator: TextValidating,
                cardTypeSource: CardTypeSource,
                matchValidator: CVVToCreditCardMatchValidator,
                messageRecorder: MessageRecording) {
        super.init(
            with: .cardCVV,
            validator: validator,
            formatter: TextFormatterFactory.cardCVV,
            textMatcher: matchValidator,
            messageRecorder: messageRecorder
        )
        
        cardTypeSource.cardType
            .map { type in
                switch type {
                case .mastercard:
                    return LocalizationConstants.TextField.Title.Card.cvc
                case .amex, .diners, .discover, .jcb, .unknown, .visa:
                    return LocalizationConstants.TextField.Title.Card.cvv
                }
            }
            .bind(to: titleRelay)
            .disposed(by: disposeBag)
    }
}
