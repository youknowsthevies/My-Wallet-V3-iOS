//
//  TransferAllCoordinator.swift
//  Blockchain
//
//  Created by kevinwu on 5/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Foundation
import PlatformUIKit

/// Coordinator for the transfer all flow.
@objc class TransferAllCoordinator: NSObject, Coordinator {
    static let shared = TransferAllCoordinator()

    // class function declared so that the TransferAllCoordinator singleton can be accessed from obj-C
    @objc class func sharedInstance() -> TransferAllCoordinator {
        TransferAllCoordinator.shared
    }
    
    private let loadingViewPresenter: LoadingViewPresenting

    private init(loadingViewPresenter: LoadingViewPresenting = resolve()) {
        self.loadingViewPresenter = loadingViewPresenter
        super.init()
        WalletManager.shared.transferAllDelegate = self
    }

    private var transferAllController: TransferAllFundsViewController?

    private var tabControllerManager: TabControllerManager? {
        AppCoordinator.shared.tabControllerManager
    }

    func start() {
        transferAllController = TransferAllFundsViewController()
        let navigationController = BCNavigationController(
            rootViewController: transferAllController!,
            title: LocalizationConstants.SendAsset.transferAllFunds
        )
        let tabViewController = AppCoordinator.shared.tabControllerManager?.tabViewController
        tabViewController?.topMostViewController!.present(navigationController, animated: true, completion: nil)
    }

    @objc func start(withDelegate delegate: TransferAllPromptDelegate) {
        start()
        transferAllController?.delegate = delegate
    }

    @objc func startWithSendScreen() {
        transferAllController = nil
        tabControllerManager?.setupTransferAllFunds()
    }
}

extension TransferAllCoordinator: WalletTransferAllDelegate {
    func updateTransferAll(amount: NSNumber, fee: NSNumber, addressesUsed: [Any]) {
        if transferAllController != nil {
            transferAllController?.updateTransferAllAmount(amount, fee: fee, addressesUsed: addressesUsed)
        } else {
            tabControllerManager?.updateTransferAll(amount: amount, fee: fee, addressesUsed: addressesUsed)
        }
    }

    func showSummaryForTransferAll() {
        if transferAllController != nil {
            transferAllController?.showSummaryForTransferAll()
            loadingViewPresenter.hide()
        } else {
            tabControllerManager?.showSummaryForTransferAll()
        }
    }

    func sendDuringTransferAll(secondPassword: String?) {
        if transferAllController != nil {
            transferAllController?.sendDuringTransferAll(secondPassword)
        } else {
            tabControllerManager?.sendDuringTransferAll(secondPassword: secondPassword)
        }
    }

    func didErrorDuringTransferAll(error: String, secondPassword: String?) {
        tabControllerManager?.didErrorDuringTransferAll(error: error, secondPassword: secondPassword)
    }
}
