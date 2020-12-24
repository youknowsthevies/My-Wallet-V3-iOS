//
//  BanksSectionPresenter.swift
//  Blockchain
//
//  Created by Daniel on 22/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import BuySellUIKit
import PlatformKit
import RxSwift

final class BanksSectionPresenter: SettingsSectionPresenting {
    let sectionType: SettingsSectionType = .banks
    
    var state: Observable<SettingsSectionLoadingState> {
        interactor.state
            .flatMap(weak: self) { (self, state) -> Observable<SettingsSectionLoadingState> in
                switch state {
                case .invalid:
                    return .just(.loaded(next: .empty))
                case .calculating:
                    let cells = [SettingsCellViewModel(cellType: .banks(.skeleton(0)))]
                    return .just(.loaded(next: .some(.init(sectionType: self.sectionType, items: cells))))
                case .value(let data):
                    let isAbleToAddNew = self.addPaymentMethodCellPresenters.map { $0.isAbleToAddNew }
                    return Observable
                        .zip(isAbleToAddNew)
                        .take(1)
                        .map { isAbleToAddNew -> [SettingsCellViewModel] in
                            let presenters = zip(isAbleToAddNew, self.addPaymentMethodCellPresenters)
                                .filter { $0.0 }
                                .map { $0.1 }
                            
                            return Array.init(data) + Array.init(presenters)
                        }
                        .map { viewModels in
                            guard !viewModels.isEmpty else {
                                return .loaded(next: .empty)
                            }
                            let sectionViewModel = SettingsSectionViewModel(
                                sectionType: self.sectionType,
                                items: viewModels
                            )
                            return .loaded(next: .some(sectionViewModel))
                        }
                }
            }
            .share()
    }
    
    // MARK: - Private Properties

    private let addPaymentMethodCellPresenters: [AddPaymentMethodCellPresenter]
    private let interactor: BanksSettingsSectionInteractor
    
    // MARK: - Setup
    
    init(interactor: BanksSettingsSectionInteractor) {
        self.interactor = interactor
        addPaymentMethodCellPresenters = interactor.addPaymentMethodInteractors
            .map {
                AddPaymentMethodCellPresenter(interactor: $0)
            }
    }
}

private extension Array where Element == SettingsCellViewModel {
    init(_ presenters: [AddPaymentMethodCellPresenter]) {
        self = presenters
            .map { SettingsCellViewModel(cellType: .banks(.add($0))) }
    }
    
    init(_ viewModels: [BeneficiaryLinkedBankViewModel]) {
        self = viewModels
            .map {
                SettingsCellViewModel(cellType: .banks(.linked($0)))
            }
    }
    
    init(_ beneficiaries: [Beneficiary]) {
        self = beneficiaries
            .map {
                SettingsCellViewModel(cellType: .banks(.linked(BeneficiaryLinkedBankViewModel(data: $0))))
            }
    }
}
