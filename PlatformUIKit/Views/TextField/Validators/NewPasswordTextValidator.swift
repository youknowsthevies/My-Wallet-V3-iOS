//
//  NewPasswordTextValidator.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxRelay
import zxcvbn_ios

/// Password text validator
final class NewPasswordTextValidator: NewPasswordValidating {
    
    // MARK: - TextValidating Properties
    
    let valueRelay = BehaviorRelay<String>(value: "")

    var validationState: Observable<TextValidationState> {
        validationStateRelay.asObservable()
    }
    
    // MARK: - NewPasswordValidating Properties
    
    var score: Observable<PasswordValidationScore> {
        return scoreRelay.asObservable()
    }
        
    // MARK: - Private Properties
    
    private let scoreRelay = BehaviorRelay<PasswordValidationScore>(value: .weak)
    private let validationStateRelay = BehaviorRelay<TextValidationState>(value: .invalid(reason: nil))
    private let validator = DBZxcvbn()
    private let disposeBag = DisposeBag()

    init() {
        valueRelay
            .map(weak: self) { (self, password) -> (DBResult?, String) in
                (self.validator.passwordStrength(password), password)
            }
            .map { (result: DBResult?, password) -> PasswordValidationScore in
                guard let result = result else { return .none }
                return PasswordValidationScore(
                    zxcvbnScore: result.score,
                    password: password
                )
            }
            // Ending up in an error state is fine (probably object deallocated)
            .catchErrorJustReturn(.weak)
            .bind(to: scoreRelay)
            .disposed(by: disposeBag)
        
        scoreRelay
            .map { $0.isValid }
            .map { $0 ? .valid : .invalid(reason: nil) }
            .bind(to: validationStateRelay)
            .disposed(by: disposeBag)
    }
}
