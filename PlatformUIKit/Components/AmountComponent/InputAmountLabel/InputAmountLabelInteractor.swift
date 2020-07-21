//
//  InputAmountLabelInteractor.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 09/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import PlatformKit

public final class InputAmountLabelInteractor {
    
    // MARK: - Properties
    
    public let scanner: MoneyValueInputScanner
    public let interactor: AmountLabelViewInteractor
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(currency: Currency, decimalAccuracy: Int = 10) {
        scanner = .init(maxDigits: .init(decimal: decimalAccuracy, fraction: currency.maxDecimalPlaces))
        self.interactor = .init(currency: currency)
        
        interactor.currency
            .map { .init(decimal: decimalAccuracy, fraction: $0.maxDecimalPlaces) }
            .bind(to: scanner.maxDigitsRelay)
            .disposed(by: disposeBag)
    }
}
