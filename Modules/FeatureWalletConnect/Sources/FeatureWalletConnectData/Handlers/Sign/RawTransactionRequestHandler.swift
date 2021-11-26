// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import EthereumKit
import FeatureWalletConnectDomain
import Foundation
import PlatformKit
import WalletConnectSwift

final class RawTransactionRequestHandler: RequestHandler {

    private let accountProvider: WalletConnectAccountProviderAPI
    private let userEvent: (WalletConnectUserEvent) -> Void
    private let responseEvent: (WalletConnectResponseEvent) -> Void
    private var cancellables: Set<AnyCancellable> = []
    private let getSession: (WCURL) -> Session?

    init(
        accountProvider: WalletConnectAccountProviderAPI = resolve(),
        userEvent: @escaping (WalletConnectUserEvent) -> Void,
        responseEvent: @escaping (WalletConnectResponseEvent) -> Void,
        getSession: @escaping (WCURL) -> Session?
    ) {
        self.accountProvider = accountProvider
        self.userEvent = userEvent
        self.responseEvent = responseEvent
        self.getSession = getSession
    }

    func canHandle(request: Request) -> Bool {
        Method(rawValue: request.method) != nil
    }

    func handle(request: Request) {
        accountProvider
            .defaultAccount
            .map { [responseEvent, getSession] defaultAccount -> WalletConnectUserEvent? in
                guard Method(rawValue: request.method) != nil else {
                    return nil
                }
                guard let session = getSession(request.url) else {
                    return nil
                }
                guard let transaction = try? request.parameter(of: String.self, at: 0) else {
                    return nil
                }
                let target = EthereumRawTransactionTarget(
                    dAppAddress: session.dAppInfo.peerMeta.url.absoluteString,
                    dAppName: session.dAppInfo.peerMeta.name,
                    rawTransaction: Data(hex: transaction),
                    onTxCompleted: { transactionResult in
                        switch transactionResult {
                        case .signed(let string):
                            responseEvent(.signature(string, request))
                        case .hashed(let txHash, _, _):
                            responseEvent(.transactionHash(txHash, request))
                        case .unHashed:
                            break
                        }
                        return .empty()
                    }
                )
                return .sendTransaction(defaultAccount, target)
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
}

extension RawTransactionRequestHandler {

    private enum Method: String {
        case sendRawTransaction = "eth_sendRawTransaction"
    }
}
