// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import JavaScriptCore
import PlatformKit
import ToolKit

public enum EthereumJSInteropDispatcherError: Error {
    case jsError(String)
    case unknown
}

@objc public protocol EthereumJSInteropDelegateAPI {
    func didGetAccounts(_ accounts: JSValue)
    func didFailToGetAccounts(errorMessage: JSValue)

    func didRecordLastTransaction()
    func didFailToRecordLastTransaction(errorMessage: JSValue)
}

public protocol EthereumJSInteropDispatcherAPI {
    var getAccounts: Dispatcher<[[String: Any]]> { get }
    var recordLastTransaction: Dispatcher<Void> { get }
}

public class EthereumJSInteropDispatcher: EthereumJSInteropDispatcherAPI {
    static let shared = EthereumJSInteropDispatcher()

    public let getAccounts = Dispatcher<[[String: Any]]>()

    public let recordLastTransaction = Dispatcher<Void>()
}

extension EthereumJSInteropDispatcher: EthereumJSInteropDelegateAPI {
    public func didRecordLastTransaction() {
        recordLastTransaction.sendSuccess(with: ())
    }

    public func didFailToRecordLastTransaction(errorMessage: JSValue) {
        sendFailure(dispatcher: recordLastTransaction, errorMessage: errorMessage)
    }

    public func didGetAccounts(_ accounts: JSValue) {
        guard let accountsDictionaries = accounts.toArray() as? [[String: Any]] else {
            getAccounts.sendFailure(.unknown)
            return
        }
        getAccounts.sendSuccess(with: accountsDictionaries)
    }

    public func didFailToGetAccounts(errorMessage: JSValue) {
        sendFailure(dispatcher: getAccounts, errorMessage: errorMessage)
    }

    private func sendFailure<T>(dispatcher: Dispatcher<T>, errorMessage: JSValue) {
        guard let message = errorMessage.toString() else {
            dispatcher.sendFailure(.unknown)
            return
        }
        Logger.shared.error(message)
        dispatcher.sendFailure(.jsError(message))
    }
}

public final class Dispatcher<Value> {
    public typealias ObserverType = (Result<Value, EthereumJSInteropDispatcherError>) -> Void

    private let lock = NSRecursiveLock()
    private var observers: [ObserverType] = []

    public func addObserver(block: @escaping ObserverType) {
        lock.lock(); defer { lock.unlock() }
        observers.append(block)
    }

    func sendSuccess(with value: Value) {
        lock.lock(); defer { lock.unlock() }
        guard let observer = observers.first else { return }
        observer(.success(value))
        removeFirstObserver()
    }

    func sendFailure(_ error: EthereumJSInteropDispatcherError) {
        lock.lock(); defer { lock.unlock() }
        guard let observer = observers.first else { return }
        observer(.failure(error))
        removeFirstObserver()
    }

    private func removeFirstObserver() {
        lock.lock(); defer { lock.unlock() }
        _ = observers.remove(at: 0)
    }
}
