//
//  WalletPickerCellItem.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxDataSources
import RxSwift

enum WalletPickerCellItem: IdentifiableType {
    
    // MARK: - Types
    
    private typealias AccessibilityId = Accessibility.Identifier.Activity.WalletPickerView
    typealias Identity = String
    
    // MARK: - Properties
    
    var identity: String {
        switch self {
        case .balance(let balanceType):
            let presenter = balanceType.presenter
            return presenter.currency.code + presenter.balanceType.description
        case .total(let presenter):
            // There's only ever one `Total` cell so, it can be
            // any string for an identifier.
            return "total"
        }
    }
    
    enum BalanceType {
        case custodial(CurrentBalanceCellPresenter)
        case nonCustodial(CurrentBalanceCellPresenter)
        
        var presenter: CurrentBalanceCellPresenter {
            switch self {
            case .custodial(let presenter):
                return presenter
            case .nonCustodial(let presenter):
                return presenter
            }
        }
    }
    
    case total(WalletBalanceCellPresenter)
    case balance(BalanceType)
    
    init(cellInteractor: WalletPickerCellInteractor) {
        switch cellInteractor {
        case .balance(let interactor, let currency):
            // NOTE: `Interest` accounts are not handled here.
            switch interactor.balanceType {
            case .custodial:
                let descriptionValue: () -> Observable<String> = {
                    .just(LocalizationConstants.DashboardDetails.BalanceCell.Description.trading)
                }
                let presenter: CurrentBalanceCellPresenter = .init(
                    interactor: interactor,
                    descriptionValue: descriptionValue,
                    currency: currency,
                    alignment: .trailing,
                    separatorVisibility: .visible,
                    descriptors: .activity(
                        cryptoAccessiblitySuffix: "\(AccessibilityId.WalletCellItem.cryptoValue)",
                        fiatAccessiblitySuffix: "\(AccessibilityId.WalletCellItem.fiatValue)"
                    )
                )
                self = .balance(.custodial(presenter))
            case .nonCustodial:
                let descriptionValue: () -> Observable<String> = {
                    .just(LocalizationConstants.DashboardDetails.BalanceCell.Description.nonCustodial)
                }
                let presenter: CurrentBalanceCellPresenter = .init(
                    interactor: interactor,
                    descriptionValue: descriptionValue,
                    currency: currency,
                    alignment: .trailing,
                    separatorVisibility: .visible,
                    descriptors: .activity(
                        cryptoAccessiblitySuffix: "\(AccessibilityId.WalletCellItem.cryptoValue)",
                        fiatAccessiblitySuffix: "\(AccessibilityId.WalletCellItem.fiatValue)"
                    )
                )
                self = .balance(.nonCustodial(presenter))
            }
        case .total(let interactor):
            self = .total(.init(interactor: interactor))
        }
    }
}
