//
//  CardNumberValidator.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 19/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import Localization
import PlatformKit

public final class CardNumberValidator: TextValidating, CardTypeSource {
            
    // MARK: - Types
    
    private typealias LocalizedString = LocalizationConstants.TextField.Gesture
    
    // MARK: - Exposed Properties
        
    /// An observable that streams the card type
    public var validationState: Observable<TextValidationState> {
        validationStateRelay.asObservable()
    }
    
    /// An observable that streams the card type
    public var cardType: Observable<CardType> {
        cardTypeRelay.asObservable()
    }
    
    public let valueRelay = BehaviorRelay<String>(value: "")
        
    // MARK: - Private Properties
    
    private let supportedCardTypes: Set<CardType>
    private let cardTypeRelay = BehaviorRelay<CardType>(value: .unknown)
    private let luhnValidator = LuhnNumberValidator()
    private let validationStateRelay = BehaviorRelay<TextValidationState>(value: .invalid(reason: nil))
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(supportedCardTypes: Set<CardType> = [.visa, .mastercard, .amex]) {
        self.supportedCardTypes = supportedCardTypes
        valueRelay
            .map { .determineType(from: $0) }
            .bind(to: cardTypeRelay)
            .disposed(by: disposeBag)
           
        Observable
            .zip(valueRelay, cardType)
            .map(weak: self) { (self, payload) in
                let (value, cardType) = payload
                
                let isSupported: Bool
                if cardType.isKnown {
                    isSupported = self.supportedCardTypes.contains(cardType)
                } else {
                    isSupported = true
                }

                guard isSupported else {
                    return .invalid(reason: LocalizedString.unsupportedCardType)
                }
                
                guard self.isValid(value) else {
                    return .invalid(reason: LocalizedString.invalidCardNumber)
                }
                
                return .valid
             }
            .bind(to: validationStateRelay)
            .disposed(by: disposeBag)
    }
    
    func supports(cardType: CardType) -> Bool {
        supportedCardTypes.contains(cardType)
    }
        
    private func isValid(_ number: String) -> Bool {
        var number = number
        number.removeAll { $0 == " " }
        
        guard luhnValidator.validate(number: number) else {
            return false
        }
        for type in CardType.all {
            let predicate = NSPredicate(format: "SELF MATCHES %@", type.regex)
            if predicate.evaluate(with: number) {
                return true
            }
        }
        return false
    }
}
