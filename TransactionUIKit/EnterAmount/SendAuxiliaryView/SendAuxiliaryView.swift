//
//  SendAuxiliaryView.swift
//  PlatformUIKit
//
//  Created by Daniel on 06/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

final class SendAuxililaryViewInteractor: SendAuxililaryViewInteractorAPI {
    
    private let contentLabelViewInteractor = ContentLabelViewInteractor()
    
    let resetToMaxAmountRelay = PublishRelay<Void>()
    var availableBalanceContentViewInteractor: ContentLabelViewInteractorAPI {
        contentLabelViewInteractor
    }
    
    func connect(stream: Observable<MoneyValue>) -> Disposable {
        stream
            .map { $0.toDisplayString(includeSymbol: true) }
            .map { ValueCalculationState.value($0) }
            .bindAndCatch(to: contentLabelViewInteractor.stateSubject)
    }
}

final class ContentLabelViewInteractor: ContentLabelViewInteractorAPI {
    
    var contentCalculationState: Observable<ValueCalculationState<String>> {
        stateSubject.asObservable()
    }
    
    let stateSubject: BehaviorSubject<ValueCalculationState<String>> = .init(value: .calculating)
}
