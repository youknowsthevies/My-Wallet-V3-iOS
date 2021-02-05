//
//  CustodialActionScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 2/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

public final class CustodialActionScreenPresenter: WalletActionScreenPresenting {
    
    // MARK: - Types

    private typealias AccessibilityId = Accessibility.Identifier.WalletActionSheet
    public typealias CellType = WalletActionCellType
    
    // MARK: - Public Properties
    
    public var sections: Observable<[WalletActionItemsSectionViewModel]> {
        sectionsRelay
            .asObservable()
    }
    
    public let assetBalanceViewPresenter: CurrentBalanceCellPresenter
    
    public var currency: CurrencyType {
        interactor.currency
    }
    
    public let selectionRelay: PublishRelay<WalletActionCellType> = .init()
    
    // MARK: - Private Properties
    
    private let sectionsRelay = BehaviorRelay<[WalletActionItemsSectionViewModel]>(value: [])
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let interactor: WalletActionScreenInteracting
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(using interactor: WalletActionScreenInteracting,
                enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
                stateService: CustodyActionStateServiceAPI,
                eligiblePaymentService: PaymentMethodsServiceAPI = resolve(),
                internalFeatureFlags: InternalFeatureFlagServiceAPI = resolve()) {
        self.interactor = interactor
        self.enabledCurrenciesService = enabledCurrenciesService
        
        let descriptionValue: () -> Observable<String> = {
            switch interactor.currency {
            case .crypto:
                return .just(LocalizationConstants.DashboardDetails.BalanceCell.Description.trading)
            case .fiat(let fiatCurrency):
                return .just(fiatCurrency.code)
            }
        }
        
        assetBalanceViewPresenter = CurrentBalanceCellPresenter(
            interactor: interactor.balanceCellInteractor,
            descriptionValue: descriptionValue,
            currency: interactor.currency,
            titleAccessibilitySuffix: "\(Accessibility.Identifier.CurrentBalanceCell.title)",
            descriptionAccessibilitySuffix: "\(Accessibility.Identifier.CurrentBalanceCell.description)",
            pendingAccessibilitySuffix: "\(Accessibility.Identifier.CurrentBalanceCell.pending)",
            descriptors: .default(
                cryptoAccessiblitySuffix: "\(AccessibilityId.CustodialAction.cryptoValue)",
                fiatAccessiblitySuffix: "\(AccessibilityId.CustodialAction.fiatValue)"
            )
        )

        Single.zip(Single.just(currency), eligiblePaymentService.paymentMethodsSingle)
            .map { (currency, methods) -> [WalletActionCellType] in
                var presenters: [DefaultWalletActionCellPresenter] = []
                switch currency {
                case .crypto(let crypto):
                    presenters.append(contentsOf: [
                        .init(currencyType: currency, action: .buy),
                        .init(currencyType: currency, action: .sell),
                        .init(currencyType: currency, action: .swap)
                    ])
                    let isTrading = interactor.accountType.isTrading
                    let isSavings = interactor.accountType.isSavings
                    if isTrading && crypto.hasNonCustodialWithdrawalSupport {
                        presenters.append(
                            .init(currencyType: currency, action: .transfer)
                        )
                    }
                    if !isSavings {
                        presenters.append(
                            .init(currencyType: currency, action: .activity)
                        )
                    }
                case .fiat(let fiatCurrency):
                    let hasEligibility = methods.first { $0.type.isSame(as: .funds(.fiat(fiatCurrency))) } != nil
                    guard hasEligibility else {
                        break
                    }
                    guard enabledCurrenciesService.depositEnabledFiatCurrencies.contains(fiatCurrency) else {
                        break
                    }
                    presenters.append(DefaultWalletActionCellPresenter(currencyType: currency, action: .deposit))

                    guard enabledCurrenciesService.withdrawEnabledFiatCurrencies.contains(fiatCurrency) else {
                        break
                    }
                    presenters.append(DefaultWalletActionCellPresenter(currencyType: currency, action: .withdraw))
                }
                return [.balance(self.assetBalanceViewPresenter)] + presenters.map { .default($0) }
            }
            .map { cellTypes in
                [WalletActionItemsSectionViewModel(items: cellTypes)]
            }
            .asObservable()
            .bindAndCatch(to: sectionsRelay)
            .disposed(by: disposeBag)
        
        selectionRelay
            .bind { model in
                guard case let .default(presenter) = model else { return }
                switch presenter.action {
                case .buy:
                    stateService.buyRelay.accept(())
                case .sell:
                    stateService.sellRelay.accept(())
                case .activity:
                    stateService.activityRelay.accept(())
                case .transfer:
                    stateService.nextRelay.accept(())
                case .deposit:
                    stateService.depositRelay.accept(())
                case .withdraw:
                    stateService.withdrawRelay.accept(())
                case .swap:
                    stateService.swapRelay.accept(())
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
}
