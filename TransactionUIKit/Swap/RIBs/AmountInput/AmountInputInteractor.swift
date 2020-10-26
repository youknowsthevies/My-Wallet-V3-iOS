//
//  AmountInputInteractor.swift
//  TransactionUIKit
//
//  Created by Paulo on 12/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RIBs
import RxSwift

protocol AmountInputRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol AmountInputPresentable: Presentable {
    var listener: AmountInputPresentableListener? { get set }
    func configure(withFrom from: String, to: String)
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol AmountInputListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func userSelected(pair: (CurrencyType, CurrencyType), amount: Decimal)
}

final class AmountInputInteractor: PresentableInteractor<AmountInputPresentable>, AmountInputInteractable, AmountInputPresentableListener {

    weak var router: AmountInputRouting?
    weak var listener: AmountInputListener?

    private let pair: (CurrencyType, CurrencyType)

    init(pair: (CurrencyType, CurrencyType),
         presenter: AmountInputPresentable) {
        self.pair = pair
        super.init(presenter: presenter)
        presenter.listener = self
    }

    func didChoose(amount: Decimal) {
        listener?.userSelected(pair: pair, amount: amount)
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        presenter.configure(withFrom: pair.0.displayCode, to: pair.1.displayCode)
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
}
