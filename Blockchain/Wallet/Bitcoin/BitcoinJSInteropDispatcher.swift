// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import JavaScriptCore
import ToolKit

@objc public protocol BitcoinJSInteropDelegateAPI {

    func didGetDefaultWalletIndex(_ walletIndex: JSValue)
    func didFailToGetDefaultWalletIndex(errorMessage: JSValue)

    func didGetWalletIndex(_ walletIndex: JSValue)
    func didFailToGetWalletIndex(errorMessage: JSValue)

    func didGetAccounts(_ accounts: JSValue)
    func didFailToGetAccounts(errorMessage: JSValue)

    func didGetHDWallet(_ wallet: JSValue)
    func didFailToGetHDWallet(errorMessage: JSValue)

    func didGetSignedPayment(_ payment: JSValue)
    func didFailToSignPayment(errorMessage: JSValue)
}

protocol BitcoinJSInteropDispatcherAPI {

    var getWalletIndex: Dispatcher<Int32> { get }

    var getDefaultWalletIndex: Dispatcher<Int> { get }

    var getAccounts: Dispatcher<String> { get }

    var getSignedPayment: Dispatcher<(String, Int)> { get }

    var getHDWallet: Dispatcher<String> { get }
}

public class BitcoinJSInteropDispatcher: BitcoinJSInteropDispatcherAPI {

    static let shared = BitcoinJSInteropDispatcher()

    let getDefaultWalletIndex = Dispatcher<Int>()

    let getWalletIndex = Dispatcher<Int32>()

    let getSignedPayment = Dispatcher<(String, Int)>()

    let getAccounts = Dispatcher<String>()

    let getHDWallet = Dispatcher<String>()
}

extension BitcoinJSInteropDispatcher: BitcoinJSInteropDelegateAPI {

    public func didGetSignedPayment(_ payment: JSValue) {
        guard let payload: String = payment.toString() else {
            getWalletIndex.sendFailure(.unknown)
            return
        }
        let values = payload.components(separatedBy: ",")
        guard let hex = values.first else {
            sendFailure(dispatcher: getSignedPayment, errorMessage: payment)
            return
        }
        guard let weight = values.last else {
            sendFailure(dispatcher: getSignedPayment, errorMessage: payment)
            return
        }
        guard let weightValue = Int(weight) else {
            sendFailure(dispatcher: getSignedPayment, errorMessage: payment)
            return
        }
        getSignedPayment.sendSuccess(with: (hex, weightValue))
    }

    public func didFailToSignPayment(errorMessage: JSValue) {
        sendFailure(dispatcher: getSignedPayment, errorMessage: errorMessage)
    }

    public func didGetWalletIndex(_ walletIndex: JSValue) {
        guard let walletIndexInt: Int32 = walletIndex.toNumber()?.int32Value else {
            getWalletIndex.sendFailure(.unknown)
            return
        }
        getWalletIndex.sendSuccess(with: walletIndexInt)
    }

    public func didFailToGetWalletIndex(errorMessage: JSValue) {
        sendFailure(dispatcher: getWalletIndex, errorMessage: errorMessage)
    }

    public func didGetDefaultWalletIndex(_ walletIndex: JSValue) {
        guard let walletIndexInt: Int = walletIndex.toNumber()?.intValue else {
            getDefaultWalletIndex.sendFailure(.unknown)
            return
        }
        getDefaultWalletIndex.sendSuccess(with: walletIndexInt)
    }

    public func didFailToGetDefaultWalletIndex(errorMessage: JSValue) {
        sendFailure(dispatcher: getDefaultWalletIndex, errorMessage: errorMessage)
    }

    public func didGetAccounts(_ accounts: JSValue) {
        guard let accountsString: String = accounts.toString() else {
            getAccounts.sendFailure(.unknown)
            return
        }
        getAccounts.sendSuccess(with: accountsString)
    }

    public func didFailToGetAccounts(errorMessage: JSValue) {
        sendFailure(dispatcher: getAccounts, errorMessage: errorMessage)
    }

    public func didGetHDWallet(_ wallet: JSValue) {
        guard let walletString: String = wallet.toString() else {
            getHDWallet.sendFailure(.unknown)
            return
        }
        getHDWallet.sendSuccess(with: walletString)
    }

    public func didFailToGetHDWallet(errorMessage: JSValue) {
        sendFailure(dispatcher: getHDWallet, errorMessage: errorMessage)
    }

    private func sendFailure<T>(dispatcher: Dispatcher<T>, errorMessage: JSValue) {
        guard let message: String = errorMessage.toString() else {
            dispatcher.sendFailure(.unknown)
            return
        }
        Logger.shared.error(message)
        dispatcher.sendFailure(.jsError(message))
    }
}
