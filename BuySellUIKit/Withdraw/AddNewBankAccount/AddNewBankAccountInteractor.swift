//
//  AddNewBankAccountBuilder.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 07/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit

typealias AddNewBankAccountDetailsInteractionState = ValueCalculationState<PaymentAccount>

enum AddNewBankAccountAction {
    case details(AddNewBankAccountDetailsInteractionState)
}

enum AddNewBankAccountEffects {
    case termsTapped(TitledLink)
    case close
}

protocol AddNewBankAccountRouting: AnyObject {
    func showTermsScreen(link: TitledLink)
}

protocol AddNewBankAccountListener: AnyObject {
    func dismissAddNewBankAccount()
}

protocol AddNewBankAccountPresentable: Presentable {
    func connect(action: Driver<AddNewBankAccountAction>) -> Driver<AddNewBankAccountEffects>
}

final class AddNewBankAccountInteractor: PresentableInteractor<AddNewBankAccountPresentable>,
                                         AddNewBankAccountInteractable {

    weak var router: AddNewBankAccountRouting?
    weak var listener: AddNewBankAccountListener?

    private let fiatCurrency: FiatCurrency
    private let paymentAccountService: PaymentAccountServiceAPI

    init(presenter: AddNewBankAccountPresentable,
         fiatCurrency: FiatCurrency,
         paymentAccountService: PaymentAccountServiceAPI = resolve()) {
        self.fiatCurrency = fiatCurrency
        self.paymentAccountService = paymentAccountService
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        let detailsAction = paymentAccountService
            .paymentAccount(for: fiatCurrency)
            .asObservable()
            .map { AddNewBankAccountDetailsInteractionState.value($0) }
            .startWith(.calculating)
            .asDriver(onErrorJustReturn: .invalid(.valueCouldNotBeCalculated))
            .map(AddNewBankAccountAction.details)
            
        presenter.connect(action: detailsAction)
            .drive(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)
    }

    func handle(effect: AddNewBankAccountEffects) {
        switch effect {
        case .close:
            listener?.dismissAddNewBankAccount()
        case .termsTapped(let link):
            router?.showTermsScreen(link: link)
        }
    }
}
