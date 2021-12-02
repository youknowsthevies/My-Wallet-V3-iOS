//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import ToolKit

extension LoggedInRootViewController: LoggedInBridge {

    func toggleSideMenu() {
        unimplemented()
    }

    func closeSideMenu() {
        unimplemented()
    }

    func send(from account: BlockchainAccount) {
        unimplemented()
    }

    func send(from account: BlockchainAccount, target: TransactionTarget) {
        unimplemented()
    }

    func sign(from account: BlockchainAccount, target: TransactionTarget) {
        unimplemented()
    }

    func receive(into account: BlockchainAccount) {
        unimplemented()
    }

    func withdraw(from account: BlockchainAccount) {
        unimplemented()
    }

    func deposit(into account: BlockchainAccount) {
        unimplemented()
    }

    func interestTransfer(into account: BlockchainAccount) {
        unimplemented()
    }

    func interestWithdraw(from account: BlockchainAccount) {
        unimplemented()
    }

    func switchToSend() {
        unimplemented()
    }

    func switchTabToSwap() {
        unimplemented()
    }

    func switchTabToReceive() {
        unimplemented()
    }

    func switchToActivity() {
        unimplemented()
    }

    func switchToActivity(for currencyType: CurrencyType) {
        unimplemented()
    }

    func showCashIdentityVerificationScreen() {
        unimplemented()
    }

    func showInterestDashboardAnnouncementScreen(isKYCVerfied: Bool) {
        unimplemented()
    }

    func showFundTrasferDetails(fiatCurrency: FiatCurrency, isOriginDeposit: Bool) {
        unimplemented()
    }

    func handleSwapCrypto(account: CryptoAccount?) {
        unimplemented()
    }

    func handleSellCrypto(account: CryptoAccount?) {
        unimplemented()
    }

    func handleBuyCrypto(account: CryptoAccount?) {
        unimplemented()
    }

    func handleBuyCrypto(currency: CryptoCurrency = .coin(.bitcoin)) {
        unimplemented()
    }

    func startBackupFlow() {
        unimplemented()
    }

    func showSettingsView() {
        unimplemented()
    }

    func reload() {
        unimplemented()
    }

    func presentKYCIfNeeded() {
        unimplemented()
    }

    func presentBuyIfNeeded(_ cryptoCurrency: CryptoCurrency) {
        unimplemented()
    }

    func enableBiometrics() {
        unimplemented()
    }

    func changePin() {
        unimplemented()
    }

    func showQRCodeScanner() {
        unimplemented()
    }
}
