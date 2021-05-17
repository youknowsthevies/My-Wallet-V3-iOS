// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

// MARK: - Builder

protocol AddNewPaymentMethodBuildable {
    func build(listener: AddNewPaymentMethodListener) -> AddNewPaymentMethodRouting
}

final class AddNewPaymentMethodBuilder: AddNewPaymentMethodBuildable {

    private let paymentMethodService: SelectPaymentMethodService

    init(paymentMethodService: SelectPaymentMethodService) {
        self.paymentMethodService = paymentMethodService
    }

    func build(listener: AddNewPaymentMethodListener) -> AddNewPaymentMethodRouting {
        let viewController = AddNewPaymentMethodViewController()
        viewController.isModalInPresentation = true
        let interactor = AddNewPaymentMethodInteractor(presenter: viewController,
                                                       paymentMethodService: paymentMethodService)
        interactor.listener = listener
        return AddNewPaymentMethodRouter(interactor: interactor, viewController: viewController)
    }
}
