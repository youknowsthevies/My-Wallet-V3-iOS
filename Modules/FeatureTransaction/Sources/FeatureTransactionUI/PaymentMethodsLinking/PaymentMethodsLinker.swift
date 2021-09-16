// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import PlatformUIKit
import UIKit

enum PaymentMethodLinkingFlowResult {
    case abandoned
    case completed(PlatformKit.PaymentMethod)
}

/// Use this protocol to present the flow to link a payment method to a user's account.
protocol PaymentMethodLinkerAPI {

    /// Presents an account linking flow modally on top of the passed-in `presenter`
    /// NOTE: This flow doesn't actually link a payment method at the moment, but only asks the user which payment method type they want to link and calls back with that.
    /// - Parameters:
    ///   - presenter: The `UIViewController` that needs to present the linking flow.
    ///   - completion: A closure called when the flow is completed or dismissed.
    func presentAccountLinkingFlow(
        from presenter: UIViewController,
        completion: @escaping (PaymentMethodLinkingFlowResult) -> Void
    )
}

final class PaymentMethodLinker: PaymentMethodLinkerAPI {

    private let selectPaymentMethodService: SelectPaymentMethodService

    private var addMethodsRouter: AddNewPaymentMethodRouting?
    private var listener: AccountLinkerListener!
    private var cancellables = Set<AnyCancellable>()

    init(selectPaymentMethodService: SelectPaymentMethodService = SelectPaymentMethodService()) {
        self.selectPaymentMethodService = selectPaymentMethodService
    }

    func presentAccountLinkingFlow(
        from presenter: UIViewController,
        completion: @escaping (PaymentMethodLinkingFlowResult) -> Void
    ) {
        precondition(
            addMethodsRouter == nil,
            "You're trying to present \(type(of: self)) when an instance is already in use."
        )
        let builder = AddNewPaymentMethodBuilder(paymentMethodService: selectPaymentMethodService)
        listener = AccountLinkerListener()
        listener.publisher
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.cleanUp()
                },
                receiveValue: completion
            )
            .store(in: &cancellables)

        let router = builder.build(listener: listener)
        let navController = UINavigationController(rootViewController: router.viewControllable.uiviewController)
        presenter.present(navController, animated: true, completion: nil)
        addMethodsRouter = router
        router.interactable.activate()
        router.load()
    }

    private func cleanUp() {
        listener = nil
        addMethodsRouter = nil
        cancellables.removeAll()
    }
}

private class AccountLinkerListener: AddNewPaymentMethodListener {

    private let subject = PassthroughSubject<PaymentMethodLinkingFlowResult, Never>()
    var publisher: AnyPublisher<PaymentMethodLinkingFlowResult, Never> {
        subject.eraseToAnyPublisher()
    }

    func closeFlow() {
        subject.send(.abandoned)
        subject.send(completion: .finished)
    }

    func navigate(with method: PaymentMethod) {
        subject.send(.completed(method))
        subject.send(completion: .finished)
    }
}
