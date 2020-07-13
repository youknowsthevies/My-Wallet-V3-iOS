//
//  ExchangeAssetAccountListPresenter.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import Localization
import RxSwift

enum ExchangeAction {
    case exchanging
    case receiving

    var title: String {
        switch self {
        case .exchanging:
            return LocalizationConstants.Swap.whatDoYouWantToExchange
        case .receiving:
            return LocalizationConstants.Swap.whatDoYouWantToReceive
        }
    }
}

protocol ExchangeAssetAccountListView: class {
    func showPicker(for assetAccounts: [AssetAccount], action: ExchangeAction)
}

/// A presenter that presents a list of `AssetAccount` that the user can
/// select to exchange crypto into or out of
class ExchangeAssetAccountListPresenter {

    private weak var view: ExchangeAssetAccountListView?
    private let assetAccountRepository: AssetAccountRepositoryAPI
    private let disposeBag = DisposeBag()

    init(
        view: ExchangeAssetAccountListView,
        assetAccountRepository: AssetAccountRepositoryAPI = AssetAccountRepository.shared
    ) {
        self.view = view
        self.assetAccountRepository = assetAccountRepository
    }

    func presentPicker(excludingAccount assetAccount: AssetAccount?, for action: ExchangeAction) {
        assetAccountRepository
            .accounts
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .map { allAccounts in
                allAccounts
                    .filter { $0 != assetAccount }
                    .filter { $0.address.cryptoCurrency.hasSwapSupport }
            }
            .subscribe(onSuccess: { [weak self] filteredAccounts in
                guard let self = self else { return }
                self.view?.showPicker(for: filteredAccounts, action: action)
            })
            .disposed(by: disposeBag)
    }
}
