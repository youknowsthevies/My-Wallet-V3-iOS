// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import Errors
import FeatureCardIssuingDomain
import Localization
import MoneyKit
import ToolKit

public enum CardOrderingError: Error, Equatable {
    case noAddress
    case noProduct
}

public enum CardOrderingResult: Equatable {
    case created
    case cancelled
}

public enum CardOrderingAction: Equatable, BindableAction {

    case setStep(CardOrderingState.Step)
    case cardCreationResponse(Result<Card, NabuNetworkError>)
    case fetchProducts
    case productsResponse(Result<[Product], NabuNetworkError>)
    case fetchAddress(Result<Card.Address, CardOrderingError>)
    case close(CardOrderingResult)
    case displayEligibleCountryList
    case displayEligibleStateList
    case selectProduct(Int)
    case binding(BindingAction<CardOrderingState>)
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

    @BindableState var isOrderProcessingVisible = false
    @BindableState var isProductSelectionVisible = false
    @BindableState var isProductDetailsVisible = false

    @BindableState var isLegalViewVisible = false
    @BindableState var termsAccepted = false
    @BindableState var selectedProductIndex: Int = 0

    var products: [Product] = []
    var selectedProduct: Product?
    var error: NabuNetworkError?

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

private enum Constants {
    static let tempAuthorizedSsn = "111111110"
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
        guard let product = state.selectedProduct else {
            state.orderProcessingState = .error(CardOrderingError.noProduct)
            return .none
        }
        return env.cardService
            .orderCard(product: product, at: address, with: Constants.tempAuthorizedSsn)
            .receive(on: env.mainQueue)
            .catchToEffect(CardOrderingAction.cardCreationResponse)
    case .fetchAddress(.failure(let error)):
        state.orderProcessingState = .error(error)
        return .none
    case .fetchProducts:
        return env
            .productsService
            .fetchProducts()
            .receive(on: env.mainQueue)
            .catchToEffect(CardOrderingAction.productsResponse)
    case .productsResponse(.success(let products)):
        state.products = products
        state.selectedProductIndex = 0
        state.selectedProduct = products[safe: 0]
        return .none
    case .productsResponse(.failure(let error)):
        state.error = error
        return .none
    case .close(let result):
        return .fireAndForget {
            env.onComplete(result)
        }
    case .displayEligibleStateList:
        return .none
    case .displayEligibleCountryList:
        return .none
    case .selectProduct(let index):
        state.selectedProductIndex = index
        state.selectedProduct = state.products[safe: index]
        return .none
    case .binding:
        return .none
    }
}
.binding()

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

struct MockServices: CardServiceAPI, ProductsServiceAPI, AccountProviderAPI, TopUpRouterAPI, SupportRouterAPI {

    let error = NabuError(id: "mock", code: .stateNotEligible, type: .unknown, description: "")
    let card = Card(
        id: "",
        type: .virtual,
        last4: "1234",
        expiry: "12/99",
        brand: .visa,
        status: .active,
        orderStatus: nil,
        createdAt: "01/10"
    )
    let accountCurrencyPair = AccountCurrency(
        accountCurrency: "BTC"
    )
    let accountBalancePair = AccountBalance(
        balance: Money(
            value: "50000",
            symbol: "BTC"
        )
    )
    let settings = CardSettings(
        locked: true,
        swipePaymentsEnabled: true,
        contactlessPaymentsEnabled: true,
        preAuthEnabled: true,
        address: Card.Address(
            line1: "48 rue de la Santé",
            line2: nil,
            city: "Paris",
            postcode: "75001",
            state: nil,
            country: "FR"
        )
    )

    func orderCard(
        product: Product,
        at address: Card.Address,
        with ssn: String
    ) -> AnyPublisher<Card, NabuNetworkError> {
        .just(card)
    }

    func fetchCards() -> AnyPublisher<[Card], NabuNetworkError> {
        .just([card])
    }

    func fetchCard(with id: String) -> AnyPublisher<Card, NabuNetworkError> {
        .just(card)
    }

    func delete(card: Card) -> AnyPublisher<Card, NabuNetworkError> {
        .just(card)
    }

    func helperUrl(for card: Card) -> AnyPublisher<URL, NabuNetworkError> {
        .just(URL(string: "https://blockchain.com/")!)
    }

    func generatePinToken(for card: Card) -> AnyPublisher<String, NabuNetworkError> {
        .just("")
    }

    func fetchLinkedAccount(for card: Card) -> AnyPublisher<AccountCurrency, NabuNetworkError> {
        .just(accountCurrencyPair)
    }

    func update(account: AccountBalance, for card: Card) -> AnyPublisher<AccountCurrency, NabuNetworkError> {
        .just(accountCurrencyPair)
    }

    func fetchProducts() -> AnyPublisher<[Product], NabuNetworkError> {
        .just([
            Product(productCode: "0", price: .init(value: "0.0", symbol: "BTC"), brand: .visa, type: .virtual),
            Product(productCode: "1", price: .init(value: "0.1", symbol: "BTC"), brand: .visa, type: .physical)
        ])
    }

    func eligibleAccounts(for card: Card) -> AnyPublisher<[AccountBalance], NabuNetworkError> {
        .just([accountBalancePair])
    }

    func selectAccount(for card: Card) -> AnyPublisher<AccountBalance, NabuNetworkError> {
        .just(accountBalancePair)
    }

    func linkedAccount(for card: Card) -> AnyPublisher<AccountSnapshot?, Never> {
        .just(nil)
    }

    func lock(card: Card) -> AnyPublisher<Card, NabuNetworkError> {
        .just(card)
    }

    func unlock(card: Card) -> AnyPublisher<Card, NabuNetworkError> {
        .just(card)
    }

    func openBuyFlow(for currency: CryptoCurrency?) {}

    func openBuyFlow(for currency: FiatCurrency?) {}

    func openSwapFlow() {}

    func handleSupport() {}
}
#endif
