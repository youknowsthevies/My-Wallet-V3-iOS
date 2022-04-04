// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import NabuNetworkError
import ToolKit

public enum CardOrderingError: Error, Equatable {
    case noAddress
}

public enum CardOrderingResult: Equatable {
    case created
    case cancelled
}

public enum CardOrderingAction: Equatable {

    case setStep(CardOrderingState.Step)
    case cardCreationResponse(Result<Card, NabuNetworkError>)
    case fetchAddress(Result<Card.Address, CardOrderingError>)
    case close(CardOrderingResult)
}

public struct CardOrderingState: Equatable {

    public enum Step: String, Equatable {
        case intro
        case selection
        case creating
        case link
    }

    public enum OrderProcessingState: Equatable {
        public static func == (
            lhs: CardOrderingState.OrderProcessingState,
            rhs: CardOrderingState.OrderProcessingState
        ) -> Bool {
            switch (lhs, rhs) {
            case (.processing, .processing),
                 (.success, .success),
                 (.none, .none),
                 (.error, .error):
                return true
            default:
                return false
            }
        }

        case processing
        case success
        case error(Error)
        case none
    }

    var step: Step

    var isOrderProcessingVisible = false
    var isProductSelectionVisible = false
    var isProductDetailsVisible = false

    var orderProcessingState: OrderProcessingState = .none

    public init(step: Step = .intro) {
        self.step = step
    }
}

public struct CardOrderingEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let cardService: CardServiceAPI
    let productsService: ProductsServiceAPI
    let address: AnyPublisher<Card.Address, CardOrderingError>
    let onComplete: (CardOrderingResult) -> Void

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        cardService: CardServiceAPI,
        productsService: ProductsServiceAPI,
        address: AnyPublisher<Card.Address, CardOrderingError>,
        onComplete: @escaping (CardOrderingResult) -> Void
    ) {
        self.mainQueue = mainQueue
        self.cardService = cardService
        self.productsService = productsService
        self.address = address
        self.onComplete = onComplete
    }
}

public let cardOrderingReducer = Reducer<
    CardOrderingState,
    CardOrderingAction,
    CardOrderingEnvironment
> { state, action, env in

    switch action {
    case .setStep(let step):
        state.step = step
        switch step {
        case .intro:
            state.isOrderProcessingVisible = false
            state.isProductDetailsVisible = false
            state.isProductSelectionVisible = false
        case .selection:
            state.isProductSelectionVisible = true
            state.isOrderProcessingVisible = false
            state.isProductDetailsVisible = false
        case .creating:
            state.orderProcessingState = .processing
            state.isOrderProcessingVisible = true
            return env
                .address
                .catchToEffect(CardOrderingAction.fetchAddress)
        case .link:
            ()
        }
        return .none
    case .cardCreationResponse(.success(let card)):
        state.orderProcessingState = .success
        return .none
    case .cardCreationResponse(.failure(let error)):
        state.orderProcessingState = .error(error)
        return .none
    case .fetchAddress(.success(let address)):
        return env
            .productsService
            .fetchProducts()
            .map {
                $0.first(where: { product in product.type == .virtual })
            }
            .filter { $0 != nil }
            .flatMap { env.cardService.orderCard(product: $0!, at: address, with: "111111110") }
            .receive(on: env.mainQueue)
            .catchToEffect(CardOrderingAction.cardCreationResponse)
    case .fetchAddress(.failure(let error)):
        state.orderProcessingState = .error(error)
        return .none
    case .close(let result):
        return .fireAndForget {
            env.onComplete(result)
        }
    }
}

#if DEBUG
extension CardOrderingEnvironment {
    static var preview: CardOrderingEnvironment {
        CardOrderingEnvironment(
            mainQueue: .main,
            cardService: MockServices(),
            productsService: MockServices(),
            address: .failure(.noAddress),
            onComplete: { _ in }
        )
    }
}

struct MockServices: CardServiceAPI, ProductsServiceAPI {
    let error = NabuError(id: nil, code: .unknown, type: .unknown, description: nil)

    func orderCard(
        product: Product,
        at address: Card.Address,
        with ssn: String
    ) -> AnyPublisher<Card, NabuNetworkError> {
        .failure(.nabuError(error))
    }

    func fetchCards() -> AnyPublisher<[Card], NabuNetworkError> {
        .failure(.nabuError(error))
    }

    func fetchCard(with id: String) -> AnyPublisher<Card, NabuNetworkError> {
        .failure(.nabuError(error))
    }

    func delete(card: Card) -> AnyPublisher<Card, NabuNetworkError> {
        .failure(.nabuError(error))
    }

    func generateSensitiveDetailsToken(for card: Card) -> AnyPublisher<String, NabuNetworkError> {
        .just("")
    }

    func generatePinToken(for card: Card) -> AnyPublisher<String, NabuNetworkError> {
        .just("")
    }

    func fetchLinkedWallets(for card: Card) -> AnyPublisher<[Wallet], NabuNetworkError> {
        .failure(.nabuError(error))
    }

    func update(wallets: [Wallet], for card: Card) -> AnyPublisher<[String], NabuNetworkError> {
        .failure(.nabuError(error))
    }

    func fetchSettings(for card: Card) -> AnyPublisher<CardSettings, NabuNetworkError> {
        .failure(.nabuError(error))
    }

    func update(settings: CardSettings, for card: Card) -> AnyPublisher<CardSettings, NabuNetworkError> {
        .failure(.nabuError(error))
    }

    func fetchProducts() -> AnyPublisher<[Product], NabuNetworkError> {
        .just([])
    }
}
#endif
