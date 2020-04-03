//
//  CVVToCreditCardMatchValidator.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 24/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

public final class CVVToCreditCardMatchValidator: TextMatchValidatorAPI {
    
    // MARK: - Exposed Properties
    
    /// An observable that streams the validation state for the streams
    public var validationState: Observable<TextValidationState> {
        validationStateRelay.asObservable()
    }
    
    // MARK: - Accessors

    private let validationStateRelay = BehaviorRelay<TextValidationState>(value: .valid)
    private let disposeBag = DisposeBag()
    
    public init(cvvTextSource: TextSource, cardTypeSource: CardTypeSource, invalidReason: String) {
        Observable
            .combineLatest(cvvTextSource.valueRelay, cardTypeSource.cardType)
            .map { (payload: (cvv: String, cardType: CardType?)) in
                guard let cardType = payload.cardType else { return true }
                return payload.cvv.count == cardType.cvvLength
            }
            .map { $0 ? .valid : .invalid(reason: invalidReason) }
            .bind(to: validationStateRelay)
            .disposed(by: disposeBag)
    }
}
