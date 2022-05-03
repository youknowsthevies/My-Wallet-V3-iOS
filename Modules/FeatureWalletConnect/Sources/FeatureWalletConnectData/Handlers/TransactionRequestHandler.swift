// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BigInt
import Combine
import DIKit
import EthereumKit
import FeatureWalletConnectDomain
import Foundation
import PlatformKit
import ToolKit
import WalletConnectSwift

final class TransactionRequestHandler: RequestHandler {

    private let accountProvider: WalletConnectAccountProviderAPI
    private let analyticsEventRecorder: AnalyticsEventRecorderAPI
    private let userEvent: (WalletConnectUserEvent) -> Void
    private let responseEvent: (WalletConnectResponseEvent) -> Void
    private var cancellables: Set<AnyCancellable> = []
    private let getSession: (WCURL) -> Session?

    init(
        accountProvider: WalletConnectAccountProviderAPI = resolve(),
        analyticsEventRecorder: AnalyticsEventRecorderAPI = resolve(),
        userEvent: @escaping (WalletConnectUserEvent) -> Void,
        responseEvent: @escaping (WalletConnectResponseEvent) -> Void,
        getSession: @escaping (WCURL) -> Session?
    ) {
        self.accountProvider = accountProvider
        self.analyticsEventRecorder = analyticsEventRecorder
        self.userEvent = userEvent
        self.responseEvent = responseEvent
        self.getSession = getSession
    }

    func canHandle(request: Request) -> Bool {
        Method(rawValue: request.method) != nil
    }

    func handle(request: Request) {
        guard let session = getSession(request.url) else {
            responseEvent(.invalid(request))
            return
        }
        let chainID = session.dAppInfo.chainId
        if BuildFlag.isInternal, chainID == nil {
            let meta = session.dAppInfo.peerMeta
            fatalError("No ChainID: '\(meta.name)', '\(meta.url.absoluteString)', '\(request.method)'")
        }

        guard let network: EVMNetwork = EVMNetwork(int: chainID) else {
            // Chain not recognised.
            responseEvent(.invalid(request))
            return
        }

        accountProvider
            .defaultAccount(network: network)
            .map { [responseEvent, analyticsEventRecorder] defaultAccount -> WalletConnectUserEvent? in
                Self.createEvent(
                    analytics: analyticsEventRecorder,
                    defaultAccount: defaultAccount,
                    network: network,
                    request: request,
                    responseEvent: responseEvent,
                    session: session
                )
            }
            .sink(
                receiveValue: { [userEvent, responseEvent] event in
                    guard let event = event else {
                        responseEvent(.invalid(request))
                        return
                    }
                    userEvent(event)
                }
            )
            .store(in: &cancellables)
    }

    /// Creates a `WalletConnectUserEvent.sendTransaction(,)` or `WalletConnectUserEvent.signTransaction(,)`
    /// from input data.
    private static func createEvent(
        analytics: AnalyticsEventRecorderAPI,
        defaultAccount: SingleAccount,
        network: EVMNetwork,
        request: Request,
        responseEvent: @escaping (WalletConnectResponseEvent) -> Void,
        session: Session
    ) -> WalletConnectUserEvent? {
        guard let method = Method(rawValue: request.method) else {
            return nil
        }
        guard let transaction = try? request.parameter(of: EthereumJsonRpcTransaction.self, at: 0) else {
            return nil
        }
        let dAppName = session.dAppInfo.peerMeta.name
        let dAppAddress = session.dAppInfo.peerMeta.url.host ?? ""
        let dAppLogoURL = session.dAppInfo.peerMeta.icons.first?.absoluteString ?? ""

        let onTxCompleted: TransactionTarget.TxCompleted = { [analytics] transactionResult in
            analytics.record(
                event: method.analyticsEvent(
                    appName: dAppName,
                    action: .confirm
                )
            )
            switch transactionResult {
            case .signed(let string):
                responseEvent(.signature(string, request))
            case .hashed(let txHash, _):
                responseEvent(.transactionHash(txHash, request))
            case .unHashed:
                break
            }
            return .empty()
        }
        let onTransactionRejected: () -> AnyPublisher<Void, Never> = {
            responseEvent(.rejected(request))
            return .just(())
        }
        let target = EthereumSendTransactionTarget(
            dAppAddress: dAppAddress,
            dAppLogoURL: dAppLogoURL,
            dAppName: dAppName,
            method: method.targetMethod,
            network: network,
            onTransactionRejected: onTransactionRejected,
            onTxCompleted: onTxCompleted,
            transaction: transaction
        )
        return method.userEvent(
            account: defaultAccount,
            target: target
        )
    }
}

extension TransactionRequestHandler {

    private enum Method: String {
        case sendTransaction = "eth_sendTransaction"
        case signTransaction = "eth_signTransaction"

        var targetMethod: EthereumSendTransactionTarget.Method {
            switch self {
            case .sendTransaction:
                return .send
            case .signTransaction:
                return .sign
            }
        }

        func userEvent(
            account: SingleAccount,
            target: EthereumSendTransactionTarget
        ) -> WalletConnectUserEvent {
            switch self {
            case .sendTransaction:
                return .sendTransaction(account, target)
            case .signTransaction:
                return .signTransaction(account, target)
            }
        }

        func analyticsEvent(
            appName: String,
            action: AnalyticsEvents.New.WalletConnect.Action
        ) -> AnalyticsEvent {
            switch self {
            case .sendTransaction:
                return AnalyticsEvents.New.WalletConnect
                    .dappRequestActioned(
                        action: action,
                        appName: appName,
                        method: .sendTransaction
                    )
            case .signTransaction:
                return AnalyticsEvents.New.WalletConnect
                    .dappRequestActioned(
                        action: action,
                        appName: appName,
                        method: .signTransaction
                    )
            }
        }
    }
}
