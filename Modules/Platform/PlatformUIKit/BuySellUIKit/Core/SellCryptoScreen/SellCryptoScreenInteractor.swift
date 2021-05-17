// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift

public struct SellCryptoInteractionData {

    // TODO: Daniel - Remove and replace with a real account
    struct AnyAccount {
        let id: String
        let currencyType: CurrencyType
    }
    
    let source: AnyAccount
    let destination: AnyAccount
}

final class SellCryptoScreenInteractor: EnterAmountScreenInteractor {

    // MARK: - Types
    
    enum State {
        case inBounds(data: CandidateOrderDetails)
        case tooLow(min: MoneyValue)
        case tooHigh(max: MoneyValue)
        case empty
                
        var isValid: Bool {
            switch self {
            case .inBounds:
                return true
            default:
                return false
            }
        }
        
        var isEmpty: Bool {
            switch self {
            case .empty:
                return true
            default:
                return false
            }
        }
    }
    
    override var selectedCurrencyType: Observable<CurrencyType> {
        .just(data.source.currencyType)
    }
    
    override var hasValidState: Observable<Bool> {
        stateRelay.map { $0.isValid }
    }
    
    var state: Observable<State> {
        stateRelay.asObservable()
    }
    
    /// Streams a `KycState` indicating whether the user should complete KYC
    var currentKycState: Single<Result<KycState, Error>> {
        kycTiersService.fetchTiers()
            .map { $0.isTier2Approved }
            .mapToResult(successMap: { $0 ? .completed : .shouldComplete })
    }
    
    /// Streams a boolean indicating whether the user is eligible to Simple Buy
    var currentEligibilityState: Observable<Result<Bool, Error>> {
        eligibilityService
            .fetch()
            .mapToResult()
            .asObservable()
    }

    /// The (optional) data, in case the state's value is `inBounds`.
    /// `nil` otherwise.
    var candidateOrderDetails: Observable<CandidateOrderDetails?> {
        state
            .map { state in
                switch state {
                case .inBounds(data: let data):
                    return data
                default:
                    return nil
                }
            }
    }

    // MARK: - Interactors
    
    let auxiliaryViewInteractor: SendAuxiliaryViewInteractorAPI
    
    // MARK: - Injected
    
    let data: SellCryptoInteractionData
    private let balanceProvider: BalanceProviding
    private let eligibilityService: EligibilityServiceAPI
    private let kycTiersService: KYCTiersServiceAPI
    private let orderCreationService: OrderCreationServiceAPI
    private let pairsService: SupportedPairsInteractorServiceAPI

    // MARK: - Accessors

    /// Calculation state of the supported pairs
    private var pairsCalculationState: Observable<BuyCryptoSupportedPairsCalculationState> {
        pairsCalculationStateRelay.asObservable()
    }

    /// The fiat-crypto pairs
    private let pairsCalculationStateRelay = BehaviorRelay<BuyCryptoSupportedPairsCalculationState>(
        value: .invalid(.empty)
    )

    private let stateRelay: BehaviorRelay<State>
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(kycTiersService: KYCTiersServiceAPI = resolve(),
         pairsService: SupportedPairsInteractorServiceAPI = resolve(),
         eligibilityService: EligibilityServiceAPI = resolve(),
         data: SellCryptoInteractionData,
         priceService: PriceServiceAPI = resolve(),
         balanceProvider: BalanceProviding,
         fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
         cryptoCurrencySelectionService: CryptoCurrencyServiceAPI & SelectionServiceAPI,
         initialActiveInput: ActiveAmountInput,
         orderCreationService: OrderCreationServiceAPI = resolve()) {
        self.eligibilityService = eligibilityService
        self.pairsService = pairsService
        self.kycTiersService = kycTiersService
        self.orderCreationService = orderCreationService
        self.data = data
        self.balanceProvider = balanceProvider
        stateRelay = BehaviorRelay(value: .empty)
        auxiliaryViewInteractor = SendAuxiliaryViewInteractor(
            balanceProvider: balanceProvider,
            currencyType: data.source.currencyType
        )
                
        super.init(
            priceService: priceService,
            fiatCurrencyService: fiatCurrencyService,
            cryptoCurrencySelectionService: cryptoCurrencySelectionService,
            initialActiveInput: initialActiveInput
        )
    }

    override func didLoad() {
        let sourceAccount = self.data.source
        let sourceAccountCurrency = sourceAccount.currencyType
        let destinationAccountCurrency = data.destination.currencyType
        let priceService = self.priceService
        let amountTranslationInteractor = self.amountTranslationInteractor

        let balance = balanceProvider[sourceAccountCurrency]
            .calculationState
            .compactMap { state -> MoneyValuePair? in
                switch state {
                case .value(let pairs):
                    return pairs[.custodial(.trading)]
                case .calculating, .invalid:
                    return nil
                }
            }
            .share(replay: 1)
        
        auxiliaryViewInteractor.resetToMaxAmount
            .withLatestFrom(balance)
            .map { ($0.base, $0.quote) }
            .do(onNext: { (base, quote) in
                #warning("This will break once we enable input using either fiat or crypto")
                amountTranslationInteractor.set(amount: quote)
            })
            .map { (base, quote) -> State in
                guard !quote.isZero else { return .empty }
                guard let fiat = quote.fiatValue else { return .empty }
                guard let crypto = base.cryptoValue else { return .empty }

                let data = CandidateOrderDetails.sell(
                    fiatValue: fiat,
                    destinationFiatCurrency: destinationAccountCurrency.fiatCurrency!,
                    cryptoValue: crypto
                )
                return .inBounds(data: data)
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        pairsService.fetch()
            .map { .value($0) }
            .catchErrorJustReturn(.invalid(.valueCouldNotBeCalculated))
            .startWith(.invalid(.empty))
            .bindAndCatch(to: pairsCalculationStateRelay)
            .disposed(by: disposeBag)

        let pairs = pairsCalculationState
            .compactMap { $0.value }

        let pairForCryptoCurrency = Observable
            .combineLatest(
                pairs,
                cryptoCurrencySelectionService.selectedData
            )
            .map { (pairs, item) -> SupportedPairs.Pair? in
                pairs.pairs(per: item.cryptoCurrency).first
            }

        Observable
            .combineLatest(
                amountTranslationInteractor.fiatAmount,
                amountTranslationInteractor.cryptoAmount,
                balance,
                fiatCurrencyService.fiatCurrencyObservable,
                pairForCryptoCurrency
            )
            .map { (fiatAmount, cryptoAmount, balance, fiatCurrency, pair) -> State in
                /// There must be a pair to compare to before calculation begins
                guard let pair = pair else {
                    return .empty
                }
                let minFiatValue = pair.minFiatValue.moneyValue
                guard !fiatAmount.isZero else {
                    return .empty
                }
                guard try fiatAmount <= balance.quote else {
                    return .tooHigh(max: balance.quote)
                }
                guard try fiatAmount >= minFiatValue else {
                    return .tooLow(min: minFiatValue)
                }
                guard let fiat = fiatAmount.fiatValue else {
                    return .empty
                }
                guard let crypto = cryptoAmount.cryptoValue else {
                    return .empty
                }
                let data = CandidateOrderDetails.sell(
                    fiatValue: fiat,
                    destinationFiatCurrency: destinationAccountCurrency.fiatCurrency!,
                    cryptoValue: crypto
                )
                return .inBounds(data: data)
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
        
        state
            .flatMapLatest { state -> Observable<AmountTranslationInteractor.State> in
                amountTranslationInteractor.activeInputRelay
                    .take(1)
                    .asSingle()
                    .flatMap { activeInput -> Single<AmountTranslationInteractor.State> in
                        switch state {
                        case .tooLow(min: let moneyValue),
                             .tooHigh(max: let moneyValue):
                            return priceService
                                .moneyValuePair(
                                    base: moneyValue.fiatValue!,
                                    cryptoCurrency: sourceAccountCurrency.cryptoCurrency!,
                                    usesFiatAsBase: activeInput == .fiat
                                )
                                .map { pair -> AmountTranslationInteractor.State in
                                    switch state {
                                    case .tooLow:
                                        return .minLimitExceeded(pair.base)
                                    case .tooHigh:
                                        return .maxLimitExceeded(pair.base)
                                    case .empty:
                                        return .empty
                                    case .inBounds:
                                        return .inBounds
                                    }
                                }
                        case .empty:
                            return .just(.empty)
                        case .inBounds:
                            return .just(.inBounds)
                        }
                    }
                    .asObservable()
            }
            .bindAndCatch(to: amountTranslationInteractor.stateRelay)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    func createOrder(from candidate: CandidateOrderDetails) -> Single<CheckoutData> {
        orderCreationService.create(using: candidate)
    }
}
