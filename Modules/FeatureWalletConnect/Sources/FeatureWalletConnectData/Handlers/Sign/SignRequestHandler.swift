// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import EthereumKit
import FeatureWalletConnectDomain
import Foundation
import PlatformKit
import WalletConnectSwift

final class SignRequestHandler: RequestHandler {

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
                guard let method = Method(rawValue: request.method) else {
                    return nil
                }
                guard let session = getSession(request.url) else {
                    return nil
                }
                guard let address = method.address(request: request) else {
                    return nil
                }
                guard let message = method.message(request: request) else {
                    return nil
                }
                let target = EthereumSignMessageTarget(
                    dAppAddress: session.dAppInfo.peerMeta.url.absoluteString,
                    dAppName: session.dAppInfo.peerMeta.name,
                    account: address,
                    message: message,
                    onTxCompleted: { transactionResult in
                        switch transactionResult {
                        case .signed(let string):
                            responseEvent(.signature(string, request))
                        default:
                            break
                        }
                        return .empty()
                    }
                )
                return .signMessage(defaultAccount, target)
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

extension SignRequestHandler {

    private enum Method: String {
        case personalSign = "personal_sign"
        case ethSign = "eth_sign"
        case ethSignTypedData = "eth_signTypedData"

        private var dataIndex: Int {
            switch self {
            case .personalSign:
                return 0
            case .ethSign, .ethSignTypedData:
                return 1
            }
        }

        private var addressIndex: Int {
            switch self {
            case .personalSign:
                return 1
            case .ethSign, .ethSignTypedData:
                return 0
            }
        }

        func address(request: Request) -> String? {
            try? request.parameter(of: String.self, at: addressIndex)
        }

        func message(request: Request) -> EthereumSignMessageTarget.Message? {
            switch self {
            case .ethSign,
                 .personalSign:
                guard let messageBytes = try? request.parameter(of: String.self, at: dataIndex) else {
                    return nil
                }
                return .data(Data(hex: messageBytes))
            case .ethSignTypedData:
                guard let typedData = try? request.parameterJson(at: dataIndex) else {
                    return nil
                }
                return .typedData(typedData)
            }
        }
    }
}
