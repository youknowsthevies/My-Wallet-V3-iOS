// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import MoneyKit
import NabuNetworkError
import ToolKit

public enum CardManagementAction: Equatable {
    case addToAppleWallet
    case cardHelperDidLoad
    case close
    case closeDetails
    case showDeleteConfirmation
    case hideDeleteConfirmation
    case delete
    case deleteCardResponse(Result<Card, NabuNetworkError>)
    case getCardResponse(Result<Card?, NabuNetworkError>)
    case getLinkedAccount
    case getLinkedAccountResponse(Result<AccountSnapshot?, Never>)
    case getCardHelperUrl
    case getCardHelperUrlResponse(Result<URL, NabuNetworkError>)
    case onAppear
    case onDisappear
    case selectLinkedAccountResponse(Result<AccountBalancePair, NabuNetworkError>)
    case setDetailsScreenVisible(Bool)
    case setLinkedAccountResponse(Result<AccountCurrency, NabuNetworkError>)
    case setLocked(Bool)
    case unlockCardResponse(Result<Card, NabuNetworkError>)
    case lockCardResponse(Result<Card, NabuNetworkError>)
    case showManagementDetails
    case showSelectLinkedAccountFlow
    case showSupportFlow
    case showTransaction(CardTransaction)
    case setTopUpFlowPresented(Bool)
    case openBuyFlow
    case openSwapFlow
}

public struct CardManagementState: Equatable {

    public struct ManagementState: Equatable {

        var isDetailScreenVisible = false
        var linkedAccount: AccountSnapshot?
        var isTopUpPresented = false
        var isDeleteCardPresented = false
        var isDeleting = false

        public init(
            isDetailScreenVisible: Bool = false,
            linkedAccount: AccountSnapshot? = nil,
            isTopUpPresented: Bool = false,
            isDeleteCardPresented: Bool = false,
            isDeleting: Bool = false
        ) {
            self.isDetailScreenVisible = isDetailScreenVisible
            self.linkedAccount = linkedAccount
            self.isTopUpPresented = isTopUpPresented
            self.isDeleteCardPresented = isDeleteCardPresented
            self.isDeleting = isDeleting
        }
    }

    var card: Card?
    var isLocked = false
    var cardHelperUrl: URL?
    var cardHelperIsReady = false
    var error: NabuNetworkError?
    var transactions: [CardTransaction] = []
    var displayedTransaction: CardTransaction?

    var management = ManagementState()

    public init(
        card: Card? = nil,
        isLocked: Bool = false,
        cardHelperUrl: URL? = nil,
        cardHelperIsReady: Bool = false,
        error: NabuNetworkError? = nil,
        transactions: [CardTransaction] = [],
        management: CardManagementState.ManagementState = ManagementState()
    ) {
        self.card = card
        self.isLocked = isLocked
        self.cardHelperUrl = cardHelperUrl
        self.cardHelperIsReady = cardHelperIsReady
        self.error = error
        self.transactions = transactions
        self.management = management
    }
}

public protocol AccountProviderAPI {
    func selectAccount(for card: Card) -> AnyPublisher<AccountBalancePair, NabuNetworkError>
    func linkedAccount(for card: Card) -> AnyPublisher<AccountSnapshot?, Never>
}

public protocol TopUpRouterAPI {
    func openBuyFlow(for currency: CryptoCurrency?)
    func openBuyFlow(for currency: FiatCurrency?)
    func openSwapFlow()
}

public protocol SupportRouterAPI {
    func handleSupport()
}

public struct CardManagementEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let cardService: CardServiceAPI
    let productsService: ProductsServiceAPI
    let accountModelProvider: AccountProviderAPI
    let topUpRouter: TopUpRouterAPI
    let supportRouter: SupportRouterAPI
    let close: () -> Void

    public init(
        accountModelProvider: AccountProviderAPI,
        cardService: CardServiceAPI,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        productsService: ProductsServiceAPI,
        supportRouter: SupportRouterAPI,
        topUpRouter: TopUpRouterAPI,
        close: @escaping () -> Void
    ) {
        self.mainQueue = mainQueue
        self.cardService = cardService
        self.productsService = productsService
        self.accountModelProvider = accountModelProvider
        self.supportRouter = supportRouter
        self.topUpRouter = topUpRouter
        self.close = close
    }
}

// swiftlint:disable closure_body_length
public let cardManagementReducer = Reducer<
    CardManagementState,
    CardManagementAction,
    CardManagementEnvironment
> { state, action, env in

    switch action {
    case .close:
        return .fireAndForget {
            env.close()
        }
    case .closeDetails:
        state.management.isDetailScreenVisible = false
        return .none
    case .onAppear:
        return env.cardService
            .fetchCards()
            .map { cards in
                cards.first(where: { card in
                    card.status == .active
                        || card.status == .locked
                })
            }
            .catchToEffect(CardManagementAction.getCardResponse)
    case .onDisappear:
        return .none
    case .showManagementDetails:
        state.management.isDetailScreenVisible = true
        return .none
    case .showSelectLinkedAccountFlow:
        guard let card = state.card else {
            return .none
        }
        return env
            .accountModelProvider
            .selectAccount(for: card)
            .subscribe(on: env.mainQueue)
            .receive(on: env.mainQueue)
            .catchToEffect(CardManagementAction.selectLinkedAccountResponse)
    case .selectLinkedAccountResponse(.success(let account)):
        guard let card = state.card else {
            return .none
        }
        return env.cardService
            .update(account: account, for: card)
            .catchToEffect(CardManagementAction.setLinkedAccountResponse)
    case .selectLinkedAccountResponse(.failure(let error)):
        state.error = error
        return .none
    case .setLinkedAccountResponse(.success(let account)):
        return Effect(value: CardManagementAction.getLinkedAccount)
    case .setLinkedAccountResponse(.failure(let error)):
        state.error = error
        return .none
    case .delete:
        guard let card = state.card else {
            return Effect(value: .close)
        }
        state.management.isDeleting = true
        return env.cardService
            .delete(card: card)
            .receive(on: env.mainQueue)
            .catchToEffect(CardManagementAction.deleteCardResponse)
    case .deleteCardResponse(.success):
        state.management.isDetailScreenVisible = false
        return Effect(value: .close)
    case .deleteCardResponse(.failure(let error)):
        state.management.isDetailScreenVisible = false
        state.management.isDeleting = false
        state.error = error
        return .none
    case .showSupportFlow:
        return .fireAndForget {
            env.supportRouter.handleSupport()
        }
    case .setLocked(let locked):
        guard let card = state.card,
              locked != state.isLocked
        else {
            return .none
        }

        state.isLocked = locked

        switch locked {
        case true:
            return env.cardService
                .lock(card: card)
                .catchToEffect(CardManagementAction.lockCardResponse)
        case false:
            return env.cardService
                .unlock(card: card)
                .catchToEffect(CardManagementAction.unlockCardResponse)
        }
    case .addToAppleWallet:
        return .none
    case .getCardResponse(.success(let card)):
        guard let card = card else {
            return .none
        }
        state.card = card
        state.isLocked = card.isLocked
        return Effect.merge(
            Effect(value: CardManagementAction.getLinkedAccount),
            Effect(value: CardManagementAction.getCardHelperUrl)
        )
    case .getCardResponse(.failure(let error)):
        state.error = error
        return .none
    case .getLinkedAccount:
        guard let card = state.card else {
            return .none
        }
        return env
            .accountModelProvider
            .linkedAccount(for: card)
            .receive(on: env.mainQueue)
            .catchToEffect(CardManagementAction.getLinkedAccountResponse)
    case .getLinkedAccountResponse(.success(let account)):
        state.management.linkedAccount = account
        return .none
    case .getCardHelperUrl:
        guard let card = state.card else { return .none }
        return env.cardService
            .helperUrl(for: card)
            .receive(on: env.mainQueue)
            .catchToEffect(CardManagementAction.getCardHelperUrlResponse)
    case .getCardHelperUrlResponse(.success(let cardHelperUrl)):
        state.cardHelperUrl = cardHelperUrl
        return .none
    case .getCardHelperUrlResponse(.failure(let error)):
        state.error = error
        return .none
    case .cardHelperDidLoad:
        state.cardHelperIsReady = true
        return .none
    case .setDetailsScreenVisible(let visible):
        state.management.isDetailScreenVisible = visible
        return .none
    case .lockCardResponse(.success(let card)),
         .unlockCardResponse(.success(let card)):
        state.card = card
        state.isLocked = card.isLocked
        return .none
    case .unlockCardResponse(.failure), .lockCardResponse(.failure):
        state.isLocked = state.card?.isLocked ?? false
        return .none
    case .setTopUpFlowPresented(let presented):
        state.management.isTopUpPresented = presented
        return .none
    case .openBuyFlow:
        let linkedAccount = state.management.linkedAccount
        return .fireAndForget {
            guard let crypto = linkedAccount?.cryptoCurrency else {
                env.topUpRouter.openBuyFlow(for: linkedAccount?.fiatCurrency)
                return
            }

            env.topUpRouter.openBuyFlow(for: crypto)
        }
    case .openSwapFlow:
        return .fireAndForget {
            env.topUpRouter.openSwapFlow()
        }
    case .showDeleteConfirmation:
        state.management.isDeleteCardPresented = true
        return .none
    case .hideDeleteConfirmation:
        state.management.isDeleteCardPresented = false
        return .none
    case .showTransaction(let transaction):
        state.displayedTransaction = transaction
        return .none
    }
}

#if DEBUG
extension CardManagementEnvironment {
    static var preview: CardManagementEnvironment {
        CardManagementEnvironment(
            accountModelProvider: MockServices(),
            cardService: MockServices(),
            mainQueue: .main,
            productsService: MockServices(),
            supportRouter: MockServices(),
            topUpRouter: MockServices(),
            close: {}
        )
    }
}

extension CardManagementState {
    static var preview: CardManagementState {
        CardManagementState(
            card: nil,
            isLocked: false,
            cardHelperUrl: nil,
            cardHelperIsReady: false,
            error: nil,
            transactions: [.success, .pending, .failed],
            management: .init()
        )
    }
}
#endif
