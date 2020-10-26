//
//  NewSwapInteractor.swift
//  TransactionUIKit
//
//  Created by Paulo on 12/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RIBs
import RxSwift

protocol NewSwapRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol NewSwapPresentable: Presentable {
    var listener: NewSwapPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol NewSwapListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func routeToSwap(with pair: (CurrencyType, CurrencyType)?)
}

final class NewSwapInteractor: PresentableInteractor<NewSwapPresentable>, NewSwapInteractable, NewSwapPresentableListener {

    weak var router: NewSwapRouting?
    weak var listener: NewSwapListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: NewSwapPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }

    func startSwapFlow(with pair: (CurrencyType, CurrencyType)?) {
        listener?.routeToSwap(with: pair)
    }
}
