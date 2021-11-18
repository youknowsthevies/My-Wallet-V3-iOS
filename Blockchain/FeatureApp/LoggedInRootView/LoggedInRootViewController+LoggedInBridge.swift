//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import ToolKit

extension LoggedInRootViewController: LoggedInBridge {

    func toggleSideMenu() {
        viewStore.send(.enter(into: .account))
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
        #function.peek("‼️ not implemented")
    }

    func handleSwapCrypto(account: CryptoAccount?) {
        #function.peek("‼️ not implemented")
    }

    func handleSellCrypto(account: CryptoAccount?) {
        #function.peek("‼️ not implemented")
    }

    func handleBuyCrypto(account: CryptoAccount?) {
        #function.peek("‼️ not implemented")
    }

    func handleBuyCrypto(currency: CryptoCurrency = .coin(.bitcoin)) {
        #function.peek("‼️ not implemented")
    }

    func startBackupFlow() {
        #function.peek("‼️ not implemented")
    }

    func showSettingsView() {
        viewStore.send(.enter(into: .account))
    }

    func reload() {
        #function.peek("‼️ not implemented")
    }

    func presentKYCIfNeeded() {
        #function.peek("‼️ not implemented")
    }

    func presentBuyIfNeeded(_ cryptoCurrency: CryptoCurrency) {
        #function.peek("‼️ not implemented")
    }

    func enableBiometrics() {
        #function.peek("‼️ not implemented")
    }

    func changePin() {
        #function.peek("‼️ not implemented")
    }

    func showQRCodeScanner() {
        viewStore.send(.enter(into: .QR))
    }
}
