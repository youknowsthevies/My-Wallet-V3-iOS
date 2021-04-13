//
//  LinkBankFailureScreenInteractor.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 23/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

protocol LinkBankFailureScreenRouting: ViewableRouting {}

protocol LinkBankFailureScreenPresentable: Presentable {}

protocol LinkBankFailureScreenListener: class {
    var retryAction: PublishRelay<LinkBankFlow.Action> { get }
    func closeFlow(isInteractive: Bool)
}

final class LinkBankFailureScreenInteractor: Interactor, LinkBankFailureScreenInteractable {

    weak var router: LinkBankFailureScreenRouting?
    weak var listener: LinkBankFailureScreenListener?

    let continueTapped = PublishRelay<Void>()
    let cancelTapped = PublishRelay<Void>()

    override func didBecomeActive() {
        super.didBecomeActive()

        continueTapped
            .subscribe(onNext: { [listener] _ in
                listener?.retryAction.accept(.retry)
            })
            .disposeOnDeactivate(interactor: self)

        cancelTapped
            .subscribe(onNext: { [listener] _ in
                listener?.closeFlow(isInteractive: false)
            })
            .disposeOnDeactivate(interactor: self)
    }
}
