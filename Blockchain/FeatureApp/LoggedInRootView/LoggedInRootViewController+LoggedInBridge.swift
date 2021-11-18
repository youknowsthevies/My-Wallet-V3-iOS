//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import PlatformUIKit
import ToolKit

extension LoggedInRootViewController: LoggedInBridge {

    func toggleSideMenu() {
        viewStore.send(.enter(into: .account, context: .none))
    }

    func closeSideMenu() {
        viewStore.send(.route(nil))
    }

    func send(from account: BlockchainAccount) {
        #function.peek("‼️ not implemented")
    }

    func send(from account: BlockchainAccount, target: TransactionTarget) {
        #function.peek("‼️ not implemented")
    }

    func sign(from account: BlockchainAccount, target: TransactionTarget) {
        #function.peek("‼️ not implemented")
    }

    func receive(into account: BlockchainAccount) {
        #function.peek("‼️ not implemented")
    }

    func withdraw(from account: BlockchainAccount) {
        #function.peek("‼️ not implemented")
    }

    func deposit(into account: BlockchainAccount) {
        #function.peek("‼️ not implemented")
    }

    func interestTransfer(into account: BlockchainAccount) {
        #function.peek("‼️ not implemented")
    }

    func interestWithdraw(from account: BlockchainAccount) {
        #function.peek("‼️ not implemented")
    }

    func switchToSend() {
        viewStore.send(.tab(.buyAndSell))
    }

    func switchTabToSwap() {
        viewStore.send(.tab(.buyAndSell))
    }

    func switchTabToReceive() {
        viewStore.send(.tab(.buyAndSell))
    }

    func switchToActivity() {
        viewStore.send(.tab(.activity))
    }

    func switchToActivity(for currencyType: CurrencyType) {
        viewStore.send(.tab(.activity))
    }

    func showCashIdentityVerificationScreen() {
        #function.peek("‼️ not implemented")
    }

    func showInterestDashboardAnnouncementScreen(isKYCVerfied: Bool) {
        #function.peek("‼️ not implemented")
    }

    func showFundTrasferDetails(fiatCurrency: FiatCurrency, isOriginDeposit: Bool) {
        showFundTransferDetails.stateService.showFundsTransferDetails(
            for: fiatCurrency,
            isOriginDeposit: isOriginDeposit
        )
    }

    func handleSwapCrypto(account: CryptoAccount?) {
        transactionsRouter.presentTransactionFlow(to: .swap(account))
            .sink { result in
                "\(result)".peek("🧾 \(#function)")
            }
            .store(in: &bag)
    }

    func handleSendCrypto() {
        transactionsRouter.presentTransactionFlow(to: .send(nil))
            .sink { result in
                "\(result)".peek("🧾 \(#function)")
            }
            .store(in: &bag)
    }

    func handleReceiveCrypto() {
        transactionsRouter.presentTransactionFlow(to: .receive(nil))
            .sink { result in
                "\(result)".peek("🧾 \(#function)")
            }
            .store(in: &bag)
    }

    func handleSellCrypto(account: CryptoAccount?) {
        transactionsRouter.presentTransactionFlow(to: .sell(account))
            .sink { result in
                "\(result)".peek("🧾 \(#function)")
            }
            .store(in: &bag)
    }

    func handleBuyCrypto(account: CryptoAccount?) {
        transactionsRouter.presentTransactionFlow(to: .buy(account))
            .sink { result in
                "\(result)".peek("🧾 \(#function)")
            }
            .store(in: &bag)
    }

    func handleBuyCrypto(currency: CryptoCurrency = .coin(.bitcoin)) {
        coincore
            .cryptoAccounts(for: currency, supporting: .buy, filter: .custodial)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] accounts in
                self?.handleBuyCrypto(account: accounts.first)
            }
            .store(in: &bag)
    }

    func handleDeposit() {
        #function.peek("‼️ not implemented")
    }

    func handleWithdraw() {
        #function.peek("‼️ not implemented")
    }

    func handleRewards() {
        #function.peek("‼️ not implemented")
    }

    func startBackupFlow() {
        #function.peek("‼️ not implemented")
    }

    func showSettingsView() {
        viewStore.send(.enter(into: .account, context: .none))
    }

    func reload() {
        #function.peek("‼️ not implemented")
    }

    func presentKYCIfNeeded() {
        #function.peek("‼️ not implemented")
    }

    func presentBuyIfNeeded(_ cryptoCurrency: CryptoCurrency) {
        dismiss(animated: true) { [self] in
            handleBuyCrypto(currency: cryptoCurrency)
        }
    }

    func enableBiometrics() {
        #function.peek("‼️ not implemented")
    }

    func changePin() {
        #function.peek("‼️ not implemented")
    }

    func showQRCodeScanner() {
        viewStore.send(.enter(into: .QR, context: .none))
    }
}
