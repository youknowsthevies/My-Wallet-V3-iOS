//
//  MobileNumberValidator.swift
//  PlatformUIKit
//
//  Created by AlexM on 2/10/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PhoneNumberKit

import RxSwift
import RxRelay

/// Mobile number validator. Uses `PhoneNumberKit`
/// to validate the users phone number entry
final class MobileNumberValidator: TextValidating {
    
    // MARK: - TextValidating Properties
    
    let valueRelay = BehaviorRelay<String>(value: "")
    var isValid: Observable<Bool> {
        return isValidRelay.asObservable()
    }
    
    // MARK: - Private Properties
    
    private let phoneKit = PhoneNumberKit()
    
    private let isValidRelay = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init() {
        valueRelay
            .flatMap(weak: self) { (self, value) -> Observable<Bool> in
                self.validate(value: value).asObservable()
            }
            .bind(to: isValidRelay)
            .disposed(by: disposeBag)
    }
    
    private func validate(value: String) -> Single<Bool> {
        return Single.create { [weak self] observer -> Disposable in
            guard let self = self else { return Disposables.create() }
            if value.isEmpty {
                observer(.success(false))
            } else {
                do {
                    _ = try self.phoneKit.parse(value)
                    observer(.success(true))
                } catch {
                    observer(.success(false))
                }
            }
            return Disposables.create()
        }
    }
}

