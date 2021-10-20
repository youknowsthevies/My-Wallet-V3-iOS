// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import PlatformUIKit
import UIKit

enum PaymentSecurityFlowResult {
    case abandoned
    case completed
    case pending
    case failed
}

final class PaymentSecurityRouter {

    private let routingInteractor: CardRouterInteractor
    private var cancellables = Set<AnyCancellable>()

    init(
        routingInteractor: CardRouterInteractor = .init(),
        completion: @escaping (PaymentSecurityFlowResult) -> Void
    ) {
        self.routingInteractor = routingInteractor
        routingInteractor
            .cancellation
            .asPublisher()
            .map { _ in PaymentSecurityFlowResult.abandoned }
            .replaceError(with: PaymentSecurityFlowResult.failed)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: completion)
            .store(in: &cancellables)

        routingInteractor
            .pending
            .asPublisher()
            .map { _ in PaymentSecurityFlowResult.pending }
            .replaceError(with: PaymentSecurityFlowResult.failed)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: completion)
            .store(in: &cancellables)

        routingInteractor
            .completionCardData
            .asPublisher()
            .map { _ in PaymentSecurityFlowResult.completed }
            .replaceError(with: PaymentSecurityFlowResult.failed)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: completion)
            .store(in: &cancellables)
    }

    func presentPaymentSecurity(from presentingVC: UIViewController, authorizationData: PartnerAuthorizationData) {
        let interactor = CardAuthorizationScreenInteractor(
            routingInteractor: routingInteractor
        )
        let presenter = CardAuthorizationScreenPresenter(
            interactor: interactor,
            data: authorizationData
        )
        let viewController = CardAuthorizationScreenViewController(
            presenter: presenter
        )
        presentingVC.present(viewController, animated: true, completion: nil)
    }
}
