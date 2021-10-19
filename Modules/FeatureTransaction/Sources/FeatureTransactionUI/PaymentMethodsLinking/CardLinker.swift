// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit
import UIKit

public enum CardLinkingFlowResult {
    case abandoned
    case completed
}

/// Use this protocol to present the flow to link a credit or debit card to a user's account.
public protocol CardLinkerAPI {

    /// Presents the card linking flow modally on top of the passed-in `presenter`.
    /// - Parameters:
    ///   - presenter: The `UIViewController` that needs to present the linking flow.
    ///   - completion: A closure called when the flow is completed or dismissed.
    func presentCardLinkingFlow(
        from presenter: UIViewController,
        completion: @escaping (CardLinkingFlowResult) -> Void
    )
}

final class CardLinker: CardLinkerAPI {

    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI

    private var cardRouter: CardRouter!
    private var cancellables = Set<AnyCancellable>()

    init(paymentMethodTypesService: PaymentMethodTypesServiceAPI = resolve()) {
        self.paymentMethodTypesService = paymentMethodTypesService
    }

    func presentCardLinkingFlow(
        from presenter: UIViewController,
        completion: @escaping (CardLinkingFlowResult) -> Void
    ) {
        precondition(
            cardRouter == nil,
            "Attempting to present \(type(of: self)) when an instance is already in use."
        )
        // NOTE: the presenter is currently unused because of how the `CardRouter` is implemented but it should be refactored
        let interactor = CardRouterInteractor()
        interactor
            .completionCardData
            .asPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                self?.cleanUp()
                if case .failure(let error) = completionResult {
                    Logger.shared.error(error)
                    completion(.abandoned)
                }
            } receiveValue: { _ in
                completion(.completed)
            }
            .store(in: &cancellables)

        interactor
            .cancellation
            .asPublisher()
            .replaceError(with: ())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                self?.cleanUp()
                if case .failure(let error) = completionResult {
                    Logger.shared.error(error)
                    completion(.abandoned)
                }
            } receiveValue: { _ in
                completion(.abandoned)
            }
            .store(in: &cancellables)

        let builder = CardComponentBuilder(
            routingInteractor: interactor,
            paymentMethodTypesService: paymentMethodTypesService
        )
        cardRouter = CardRouter(
            interactor: interactor,
            builder: builder,
            routingType: .modal
        )
        cardRouter.load()
    }

    private func cleanUp() {
        cardRouter = nil
        cancellables.removeAll()
    }
}
