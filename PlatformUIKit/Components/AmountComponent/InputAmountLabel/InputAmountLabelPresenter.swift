//
//  InputAmountLabelPresenter.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 09/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

public final class InputAmountLabelPresenter {
    
    // MARK: - Properties
    
    public let interactor: InputAmountLabelInteractor
    public let presenter: AmountLabelViewPresenter

    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(interactor: InputAmountLabelInteractor,
         currencyCodeSide: AmountLabelViewPresenter.CurrencyCodeSide) {
        presenter = .init(interactor: interactor.interactor, currencyCodeSide: currencyCodeSide)
        self.interactor = interactor
        
        interactor.scanner.input
            .bind(to: presenter.inputRelay)
            .disposed(by: disposeBag)
    }
}
