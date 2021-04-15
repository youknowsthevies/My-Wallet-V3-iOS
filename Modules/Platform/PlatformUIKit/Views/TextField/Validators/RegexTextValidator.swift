//
//  RegexTextValidator.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

/// Regex validator. Receives a `TextRegex` and validates the value against it.
final class RegexTextValidator: TextValidating {
    
    // MARK: - TextValidating Properties
    
    let valueRelay = BehaviorRelay<String>(value: "")
    
    var validationState: Observable<TextValidationState> {
        validationStateRelay.asObservable()
    }
        
    // MARK: - Private Properties
    
    private let validationStateRelay = BehaviorRelay<TextValidationState>(value: .invalid(reason: nil))
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init(regex: TextRegex, invalidReason: String?) {
        valueRelay
            .map { value in
                let predicate = NSPredicate(format: "SELF MATCHES %@", regex.rawValue)
                return predicate.evaluate(with: value)
            }
            .map { $0 ? .valid : .invalid(reason: invalidReason) }
            .bindAndCatch(to: validationStateRelay)
            .disposed(by: disposeBag)
    }
}
