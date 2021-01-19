//
//  SwapLandingInteractor.swift
//  TransactionUIKit
//
//  Created by Paulo on 12/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift

protocol SwapLandingRouting: ViewableRouting {
}

enum SwapLandingSelectionEffects {
    case swap(SwapTrendingPair)
    case newSwap
    case none
}

enum SwapLandingSelectionAction: Equatable {
    case items([SwapLandingSectionModel])
}

struct SwapLandingScreenState {
    let header: AccountPickerHeaderModel
    let action: SwapLandingSelectionAction
}

protocol SwapLandingPresentable: Presentable {
    var listener: SwapLandingPresentableListener? { get set }
    func connect(state: Driver<SwapLandingScreenState>) -> Driver<SwapLandingSelectionEffects>
}

protocol SwapLandingListener: AnyObject {
    func routeToSwap(with pair: SwapTrendingPair?)
}

final class SwapLandingInteractor: PresentableInteractor<SwapLandingPresentable>, SwapLandingInteractable, SwapLandingPresentableListener {

    typealias LocalizationId = LocalizationConstants.Swap.Trending
    
    weak var router: SwapLandingRouting?
    weak var listener: SwapLandingListener?
    
    private let accountProviding: BlockchainAccountProviding
    private let eligibilityService: EligibilityServiceAPI
    
    init(presenter: SwapLandingPresentable,
         accountProviding: BlockchainAccountProviding = resolve(),
         eligibilityService: EligibilityServiceAPI = resolve()) {
        self.accountProviding = accountProviding
        self.eligibilityService = eligibilityService
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()
        
        let items = initialState
            .map { state -> SwapLandingSectionModel in
                let pairs: [SwapLandingSectionItem] = state.pairViewModels.map { .pair($0) }
                let cells = Array(pairs.map { [$0] }.joined(separator: [.separator(index: .random(in: 1...Int.max))]))
                return .init(items: cells)
            }
            .map { SwapLandingSelectionAction.items([$0]) }
            .asDriverCatchError()
        
        let header = initialState
            .map(\.header)
            .asDriverCatchError()
        
        let model = Driver.zip(items, header)
            .map { SwapLandingScreenState(header: $0.1, action: $0.0) }

        let actions = Driver.merge(model)
        presenter.connect(state: actions)
            .drive(onNext: handleEffects)
            .disposeOnDeactivate(interactor: self)
    }

    override func willResignActive() {
        super.willResignActive()
    }
    
    func newSwap(withPair pair: SwapTrendingPair?) {
        listener?.routeToSwap(with: pair)
    }
    
    // MARK: - Private methods
    
    func handleEffects(_ effect: SwapLandingSelectionEffects) {
        switch effect {
        case .swap(let pair):
            listener?.routeToSwap(with: pair)
        case .newSwap:
            listener?.routeToSwap(with: nil)
        case .none:
            break
        }
    }
    
    private var initialState: Observable<State> {
        let custodialAccounts = accountProviding
            .accounts(accountType: .custodial(.trading))
            .map { accounts in
                accounts.filter { $0 is CryptoAccount }
            }
            .map { $0.map { $0 as! CryptoAccount } }
            .asObservable()
        
        let nonCustodialAccounts = accountProviding
            .accounts(accountType: .nonCustodial)
            .map { accounts in
                accounts.filter { $0 is CryptoAccount }
            }
            .map { $0.map { $0 as! CryptoAccount } }
            .asObservable()
        
        return eligibilityService
            .fetch()
            .asObservable()
            .flatMap { $0 ? custodialAccounts : nonCustodialAccounts }
            .map { accounts -> [SwapTrendingPairViewModel] in
                var pairs: [(CryptoCurrency, CryptoCurrency)] = [
                    (.bitcoin, .ethereum),
                    (.bitcoin, .pax),
                    (.bitcoin, .stellar)
                ]
                switch DevicePresenter.type {
                case .superCompact, .compact:
                    break
                case .regular:
                    pairs.append((.bitcoin, .bitcoinCash))
                case .max:
                    pairs.append((.bitcoin, .bitcoinCash))
                    pairs.append((.ethereum, .pax))
                }
                return pairs
                    .compactMap { pair -> SwapTrendingPair? in
                        accounts.trendingPair(source: pair.0, destination: pair.1)
                    }
                    .map { trendingPair -> SwapTrendingPairViewModel in
                        SwapTrendingPairViewModel(trendingPair: trendingPair)
                    }
            }
            .map { .init(pairViewModels: $0) }
    }
}

extension SwapLandingInteractor {
    struct State {
        var header: AccountPickerHeaderModel = .init(
            title: LocalizationId.Header.title,
            subtitle: LocalizationId.Header.description,
            imageContent: .init(
                imageName: "icon_swap_transaction",
                accessibility: .none,
                renderingMode: .normal,
                bundle: .transactionUIKit
            ),
            tableTitle: LocalizationId.trending
        )
        var pairViewModels: [SwapTrendingPairViewModel]
    }
}

extension Array where Element == CryptoAccount {
    func trendingPair(source sourceCurrency: CryptoCurrency,
                      destination destinationCurrency: CryptoCurrency) -> SwapTrendingPair? {
        guard let source = first(where: { $0.currencyType == sourceCurrency }) else {
            return nil
        }
        guard let destination = first(where: { $0.currencyType == destinationCurrency }) else {
            return nil
        }
        return SwapTrendingPair(
            sourceAccount: source,
            destinationAccount: destination,
            enabled: true
        )
    }
}

