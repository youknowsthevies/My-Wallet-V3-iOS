//
//  CustodialActionScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 2/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

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
    private let swapButtonVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let activityButtonVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let sendToWalletVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let interactor: WalletActionScreenInteracting
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(using interactor: WalletActionScreenInteracting,
                stateService: CustodyActionStateServiceAPI) {
        self.interactor = interactor
        
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
            alignment: .trailing,
            titleAccessibilitySuffix: "\(Accessibility.Identifier.CurrentBalanceCell.title)",
            descriptionAccessibilitySuffix: "\(Accessibility.Identifier.CurrentBalanceCell.description)",
            descriptors: .default(
                cryptoAccessiblitySuffix: "\(AccessibilityId.CustodialAction.cryptoValue)",
                fiatAccessiblitySuffix: "\(AccessibilityId.CustodialAction.fiatValue)"
            )
        )
        
        var actionCells: [WalletActionCellType] = [.balance(assetBalanceViewPresenter)]
        
        var actionPresenters: [DefaultWalletActionCellPresenter] = []
        
        switch currency {
        case .crypto:
            actionPresenters.append(contentsOf: [
                .init(currencyType: currency, action: .buy),
                .init(currencyType: currency, action: .sell),
                .init(currencyType: currency, action: .transfer),
                .init(currencyType: currency, action: .activity)
            ])
            if !interactor.balanceType.isSavings {
                actionPresenters.append(.init(currencyType: currency, action: .activity))
            }
        case .fiat:
            actionPresenters.append(contentsOf: [
                .init(currencyType: currency, action: .deposit)
            ])
        }
        
        actionCells.append(contentsOf: actionPresenters.map { .default($0) })
        sectionsRelay.accept([.init(items: actionCells)])
        
        selectionRelay
            .bind { model in
                guard case let .default(presenter) = model else { return }
                switch presenter.action {
                case .activity:
                    stateService.activityRelay.accept(())
                case .transfer:
                    stateService.nextRelay.accept(())
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
}
