//
//  TabControllerManager+Analytics.swift
//  Blockchain
//
//  Created by Daniel Huri on 03/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ActivityUIKit
import BuySellUIKit
import DIKit
import NetworkKit
import PlatformKit
import PlatformUIKit
import ToolKit
import TransactionUIKit

final class TabControllerManager: NSObject {

    // MARK: - Properties

    @objc let tabViewController: TabViewController

    // MARK: - Private Properties

    private var activityNavigationController: UINavigationController!
    private var dashboardNavigationController: UINavigationController!
    private var exchangeContainerViewController: ExchangeContainerViewController!
    private var sendNavigationViewController: UINavigationController!
    private var receiveNavigationViewController: UINavigationController!
    private var buySellViewController: UINavigationController!
    private var analyticsEventRecorder: AnalyticsEventRecording
    private let sendControllerManager: SendControllerManager
    private let sendReceiveCoordinator: SendReceiveCoordinator

    init(sendControllerManager: SendControllerManager = resolve(),
         sendReceiveCoordinator: SendReceiveCoordinator = resolve(),
         analyticsEventRecorder: AnalyticsEventRecording = resolve()) {
        self.sendControllerManager = sendControllerManager
        self.analyticsEventRecorder = analyticsEventRecorder
        tabViewController = TabViewController.makeFromStoryboard()
        self.sendReceiveCoordinator = sendReceiveCoordinator
        super.init()
        tabViewController.delegate = self
    }

    // MARK: - Show

    func showDashboard() {
        if dashboardNavigationController == nil {
            dashboardNavigationController = UINavigationController(rootViewController: DashboardViewController())
        }
        tabViewController.setActiveViewController(dashboardNavigationController,
                                                  animated: true,
                                                  index: Constants.Navigation.tabDashboard)
    }

    @objc func showTransactions() {
        if activityNavigationController == nil {
            activityNavigationController = UINavigationController(rootViewController: ActivityScreenViewController())
        }
        tabViewController.setActiveViewController(activityNavigationController,
                                                  animated: true,
                                                  index: Constants.Navigation.tabTransactions)
    }

    func showSwap() {
        if exchangeContainerViewController == nil {
            exchangeContainerViewController = ExchangeContainerViewController.makeFromStoryboard()

        }
        tabViewController.setActiveViewController(exchangeContainerViewController,
                                                  animated: true,
                                                  index: Constants.Navigation.tabSwap)
    }

    func showSend(cryptoCurrency: CryptoCurrency) {
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.showSend()
            },
            completion: { [weak self] _ in
                self?.sendControllerManager.showSend(cryptoCurrency)
            }
        )
    }

    func showSend() {
        if sendNavigationViewController == nil {
            let send = sendReceiveCoordinator.builder.send()
            sendNavigationViewController = UINavigationController(rootViewController: send)
        }
        tabViewController.setActiveViewController(sendNavigationViewController,
                                                  animated: true,
                                                  index: Constants.Navigation.tabSend)
    }

    func showReceive() {
        if receiveNavigationViewController == nil {
            let receive = sendReceiveCoordinator.builder.receive()
            receiveNavigationViewController = UINavigationController(rootViewController: receive)
        }
        tabViewController.setActiveViewController(receiveNavigationViewController,
                                                  animated: true,
                                                  index: Constants.Navigation.tabReceive)
    }

    // MARK: - SendControllerManager Redirections

    func reload() {
        sendControllerManager.reload()
    }

    func reloadAfterMultiAddressResponse() {
        sendControllerManager.reloadAfterMultiAddressResponse()
    }

    func hideSendAndReceiveKeyboards() {
        sendControllerManager.hideKeyboards()
    }

    func reloadSymbols() {
        sendControllerManager.reloadSymbols()
    }

    @objc func transferFundsToDefaultAccount(from address: String) {
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.showSend()
            },
            completion: { [weak self] _ in
                self?.sendControllerManager.transferFundsToDefaultAccount(from: address)
            }
        )
    }

    // MARK: Transfer All

    func setupTransferAllFunds() {
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.showSend()
            },
            completion: { [weak self] _ in
                self?.sendControllerManager.setupTransferAllFunds()
            }
        )
    }

    // MARK: BitPay

    func setupBitpayPayment(from url: URL) {
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.showSend()
            },
            completion: { [weak self] _ in
                self?.sendControllerManager.setupBitpayPayment(from: url)
            }
        )
    }

    func setupBitcoinPaymentFromURLHandler(with amount: String?, address: String) {
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.showSend()
            },
            completion: { [weak self] _ in
                self?.sendControllerManager.setupBitcoinPayment(amount: amount, address: address)
            }
        )
    }
}

// MARK: - WalletTransferAllDelegate

extension TabControllerManager: WalletTransferAllDelegate {
    func updateTransferAll(amount: NSNumber, fee: NSNumber, addressesUsed: [Any]) {
        sendControllerManager.updateTransferAll(amount: amount, fee: fee, addressesUsed: addressesUsed)
    }

    func showSummaryForTransferAll() {
        sendControllerManager.showSummaryForTransferAll()
    }

    func sendDuringTransferAll(secondPassword: String?) {
        sendControllerManager.sendDuringTransferAll(secondPassword: secondPassword)
    }

    func didErrorDuringTransferAll(error: String, secondPassword: String?) {
        sendControllerManager.didErrorDuringTransferAll(error: error, secondPassword: secondPassword)
    }
}

// MARK: - WalletTransactionDelegate

extension TabControllerManager: WalletTransactionDelegate {
    func onTransactionReceived() {
        SoundManager.shared.playBeep()
        NotificationCenter.default.post(Notification(name: Constants.NotificationKeys.transactionReceived))
    }

    func didPushTransaction() {
        let eventName: String
        switch sendControllerManager.bitcoinAddressSource {
        case .QR:
            eventName = "wallet_ios_tx_from_qr"
        case .URI:
            eventName = "wallet_ios_tx_from_uri"
        case .dropDown:
            eventName = "wallet_ios_tx_from_dropdown"
        case .paste:
            eventName = "wallet_ios_tx_from_paste"
        case .bitPay,
             .exchange,
             .none:
            return
        }

        guard let url = URL(string: "\(BlockchainAPI.shared.walletUrl)/event?name=\(eventName)") else {
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let session: URLSession = resolve()
        let dataTask = session.dataTask(with: urlRequest) { (data, urlResponse, error) in
            if let error = error {
                Logger.shared.debug("Error saving address input: \(error.localizedDescription)")
            }
        }
        dataTask.resume()
    }
}

// MARK: - WalletExchangeIntermediateDelegate

extension TabControllerManager: WalletExchangeIntermediateDelegate {

    /// This callback happens when an ETH account is created. This happens when a user goes to
    /// swap for the first time. This is a delegate callback from the JS layer. This needs to be
    /// refactored so that it is in a completion handler and only in `ExchangeContainerViewController`
    func didCreateEthAccountForExchange() {
        exchangeContainerViewController.showExchange()
    }
}

// MARK: - WalletSendEtherDelegate

extension TabControllerManager: WalletSendEtherDelegate {
    func didGetEtherAddressWithSecondPassword() {
        // TODO: IOS-2193
    }
}

// MARK: - WalletSettingsDelegate

extension TabControllerManager: WalletSettingsDelegate {
    func didChangeLocalCurrency() {
        sendControllerManager.didChangeLocalCurrency()
    }
}

// MARK: - TabViewControllerDelegate

extension TabControllerManager: TabViewControllerDelegate {
    func tabViewController(_ tabViewController: TabViewController, viewDidAppear animated: Bool) {
        AppCoordinator.shared.showHdUpgradeViewIfNeeded()
    }

    // MARK: - View Life Cycle

    func tabViewControllerViewDidLoad(_ tabViewController: TabViewController) {
        let walletManager = WalletManager.shared
        walletManager.settingsDelegate = self
        walletManager.sendBitcoinDelegate = self.sendControllerManager
        walletManager.sendEtherDelegate = self
        walletManager.partnerExchangeIntermediateDelegate = self
        walletManager.transactionDelegate = self
    }

    func sendClicked() {
        showSend()
    }

    func receiveClicked() {
        showReceive()
    }

    func transactionsClicked() {
        analyticsEventRecorder.record(
             event: AnalyticsEvents.Transactions.transactionsTabItemClick
         )
        showTransactions()
    }

    func dashBoardClicked() {
        showDashboard()
    }

    func swapClicked() {
        analyticsEventRecorder.record(
            event: AnalyticsEvents.Swap.swapTabItemClick
        )
        showSwap()
    }
}
