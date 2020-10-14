//
//  SwapCoordinator.swift
//  Blockchain
//
//  Created by kevinwu on 7/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import PlatformKit
import PlatformUIKit
import RxSwift
import StellarKit
import ToolKit
import KYCKit
import KYCUIKit

enum SwapCoordinatorEvent {
    case sentTransaction(orderTransaction: OrderTransaction, conversion: Conversion)
}

protocol SwapCoordinatorAPI {
    func handle(event: SwapCoordinatorEvent)
    
    /// This is used to determine if the user should see `Swap` when
    /// they tap on `Swap` in the tab bar. If the user cannot `Swap`
    /// They should see a CTA screen asking them to go through KYC.
    /// They may also see a screen that shows that they are not permitted
    /// to use `Swap` in their country. (TBD)
    func canSwap() -> Single<Bool>
}

class SwapCoordinator: SwapCoordinatorAPI {

    static let shared = SwapCoordinator()
    
    // MARK: - Private Properties

    private let walletManager: WalletManager
    private var disposable: Disposable?

    // MARK: - Navigation
    private var navigationController: ExchangeNavigationController?
    private var rootViewController: UIViewController?

    // MARK: - Entry Point
    
    func canSwap() -> Single<Bool> {
        let user = BlockchainDataRepository.shared.nabuUserSingle
        let tiersService: KYCTiersServiceAPI = resolve()
        return Single.create(subscribe: { [unowned self] observer -> Disposable in
            self.disposable = Single.zip(user, tiersService.tiers)
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { payload in
                    let tiersResponse = payload.1
                    let approved = tiersResponse.tiers.contains(where: {
                        $0.tier != .tier0 && $0.state == .verified
                    })
                    guard approved == true else {
                        observer(.success(false))
                        return
                    }
                    observer(.success(true))
                }, onError: { error in
                    observer(.error(error))
                    Logger.shared.error("Failed to get user: \(error.localizedDescription)")
                })
            return Disposables.create()
        })
    }
    
    /// Note: `initXlmAccountIfNeeded` and `createEthAccountForExchange` are now public
    /// as we now create the `ExchangeCreateViewController` in `ExchangeContainerViewController`
    /// and this screen needs to be able to create XLM accounts and/or Ethereum accounts should
    /// the user not have one.
    func initXlmAccountIfNeeded(completion: @escaping (() -> ())) {
        disposable = stellarAccountRepository.initializeMetadataMaybe()
            .flatMap({ [unowned self] _ in
                self.stellarAccountService.currentStellarAccount(fromCache: true)
            })
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { _ in
                completion()
            }, onError: { error in
                completion()
                Logger.shared.error("Failed to fetch XLM account.")
            })
    }
    
    func createEthAccountForExchange() {
        if walletManager.wallet.needsSecondPassword() {
            AuthenticationCoordinator.shared.showPasswordScreen(
                type: .etherService,
                confirmHandler: { [weak self] password in
                    self?.walletManager.wallet.createEthAccount(forExchange: password)
                }
            )
        } else {
            walletManager.wallet.createEthAccount(forExchange: nil)
        }
    }

    // TICKET: IOS-1168 - Complete error handling TODOs throughout the KYC
    private func errorMessage(for error: Error) -> String {
        guard let serverError = error as? HTTPRequestServerError,
            case let .badStatusCode(_, badStatusCodeError, _) = serverError,
            let nabuError = badStatusCodeError as? NabuNetworkError else {
                return error.localizedDescription
        }
        switch (nabuError.type, nabuError.code) {
        case (NabuNetworkErrorType.conflict.rawValue, .userRegisteredAlready):
            return LocalizationConstants.KYC.emailAddressAlreadyInUse
        default:
            return error.localizedDescription
        }
    }

    private func showLockedExchange(orderTransaction: OrderTransaction, conversion: Conversion) {
        guard let root = UIApplication.shared.keyWindow?.rootViewController else {
            Logger.shared.error("No navigation controller found")
            return
        }
        let model = ExchangeDetailPageModel(type: .locked(orderTransaction, conversion))
        let controller = ExchangeDetailViewController.make(with: model, dependencies: ExchangeServices())
        let navController = BCNavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle = .coverVertical
        root.present(navController, animated: true, completion: nil)
    }

    func handle(event: SwapCoordinatorEvent) {
        switch event {
        case .sentTransaction(orderTransaction: let transaction, conversion: let conversion):
            showLockedExchange(orderTransaction: transaction, conversion: conversion)
        }
    }

    // MARK: - Services
    private let exchangeService: ExchangeService
    private let stellarAccountService: StellarAccountAPI
    private let stellarAccountRepository: StellarWalletAccountRepositoryAPI
    private let bag: DisposeBag = DisposeBag()

    // MARK: - Lifecycle

    private init(
        walletManager: WalletManager = WalletManager.shared,
        exchangeService: ExchangeService = ExchangeService(),
        stellarAccountService: StellarAccountAPI = StellarServiceProvider.shared.services.accounts,
        stellarAccountRepository: StellarWalletAccountRepositoryAPI = StellarServiceProvider.shared.services.repository
    ) {
        self.walletManager = walletManager
        self.exchangeService = exchangeService
        self.stellarAccountService = stellarAccountService
        self.stellarAccountRepository = stellarAccountRepository
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }
}
