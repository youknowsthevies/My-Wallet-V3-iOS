// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import EthereumKit
import Foundation
import PlatformKit
import WalletConnectSwift

public enum WalletConnectSessionEvent {
    case didFailToConnect(Session.ClientMeta)
    case shouldStart(Session, (Session.WalletInfo) -> Void)
    case didConnect(Session)
    case didDisconnect(Session)
    case didUpdate(Session)
}

public enum WalletConnectUserEvent {
    case sign(SingleAccount, EthereumSignMessageTarget)
    case signTransaction(SingleAccount, EthereumSendTransactionTarget)
    case sendTransaction(SingleAccount, EthereumSendTransactionTarget)
}

public enum WalletConnectResponseEvent {
    case invalid(Request)
    case signature(String, Request)
    case transactionHash(String, Request)
}

public protocol WalletConnectServiceAPI {
    var sessionEvents: AnyPublisher<WalletConnectSessionEvent, Never> { get }
    var userEvents: AnyPublisher<WalletConnectUserEvent, Never> { get }

    func connect(_ url: String)
    func acceptConnection(_ completion: @escaping (Session.WalletInfo) -> Void)
    func denyConnection(_ completion: @escaping (Session.WalletInfo) -> Void)
}
