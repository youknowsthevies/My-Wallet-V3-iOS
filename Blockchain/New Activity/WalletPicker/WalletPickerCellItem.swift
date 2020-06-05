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
        case .balance(let presenter):
            return presenter.currency.code + presenter.balanceType.description
        case .total(let presenter):
            // TODO:
            return "total"
        }
    }
    
    case total(WalletBalanceCellPresenter)
    case balance(CurrentBalanceCellPresenter)
    
    // MARK: - Init
    
    init(cellInteractor: WalletPickerScreenInteractor.CellInteractor) {
        switch cellInteractor {
        case .balance(let interactor, let currency):
            let descriptionValue: () -> Observable<String> = {
                .just(LocalizationConstants.DashboardDetails.BalanceCell.Description.nonCustodial)
            }
            
            self = .balance(
                .init(
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
            )
        case .total(let interactor):
            self = .total(.init(interactor: interactor))
        }
    }
}
