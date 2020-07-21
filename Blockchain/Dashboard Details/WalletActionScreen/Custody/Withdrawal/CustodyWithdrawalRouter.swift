//
//  CustodyWithdrawalRouter.swift
//  Blockchain
//
//  Created by AlexM on 2/19/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

protocol CustodyWithdrawalRouterAPI: class {
    func next(to state: CustodyWithdrawalStateService.State)
    func previous()
    func start(with currency: CryptoCurrency)
    var completionRelay: PublishRelay<Void> { get }
}

final class CustodyWithdrawalRouter: CustodyWithdrawalRouterAPI, Router {
    
    // MARK: - `Router` Properties
    
    weak var topMostViewControllerProvider: TopMostViewControllerProviding!
    weak var navigationControllerAPI: NavigationControllerAPI?
    
    let completionRelay = PublishRelay<Void>()
    
    private var stateService: CustodyWithdrawalStateService!
    private let custodialAPI: CustodialServiceProviderAPI
    private let dataProviding: DataProviding
    private var currency: CryptoCurrency!
    private let disposeBag = DisposeBag()
    
    init(topMostViewControllerProvider: TopMostViewControllerProviding = UIApplication.shared,
         dataProviding: DataProviding = DataProvider.default,
         custodialAPI: CustodialServiceProviderAPI = CustodialServiceProvider.default) {
        self.dataProviding = dataProviding
        self.custodialAPI = custodialAPI
        self.topMostViewControllerProvider = topMostViewControllerProvider
    }
    
    func start(with currency: CryptoCurrency) {
        self.currency = currency
        self.stateService = CustodyWithdrawalStateService()
        
        stateService.action
            .bindAndCatch(weak: self) { (self, action) in
                switch action {
                case .previous:
                    self.previous()
                case .next(let state):
                    self.next(to: state)
                case .dismiss:
                    self.navigationControllerAPI?.dismiss(animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
        stateService.nextRelay.accept(())
    }
    
    func next(to state: CustodyWithdrawalStateService.State) {
        switch state {
        case .start:
            break
        case .withdrawal:
            showWithdrawalScreen()
        case .summary:
            showSummaryScreen()
        case .end:
            topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: { [weak self] in
                guard let self = self else { return }
                self.completionRelay.accept(())
            })
        }
    }
    
    private func showWithdrawalScreen() {
        let interactor = CustodyWithdrawalScreenInteractor(
            withdrawalService: custodialAPI.withdrawal,
            balanceFetching: dataProviding.balance[currency.currency],
            currency: currency,
            accountRepository: AssetAccountRepository.shared
        )
        let presenter = CustodyWithdrawalScreenPresenter(
            interactor: interactor,
            currency: currency,
            stateService: stateService
        )
        let controller = CustodyWithdrawalViewController(presenter: presenter)
        if #available(iOS 13.0, *) {
            controller.isModalInPresentation = true
        }
        present(viewController: controller, using: .modalOverTopMost)
    }
    
    private func showSummaryScreen() {
        let presenter = CustodyWithdrawalSummaryPresenter(
            status: stateService.completionRelay.value,
            currency: currency,
            stateService: stateService
        )
        let controller = CustodyWithdrawalSummaryViewController(presenter: presenter)
        present(viewController: controller)
    }
    
    func previous() {
        dismiss()
    }
}
