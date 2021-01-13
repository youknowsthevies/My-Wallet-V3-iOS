//
//  YodleeMessageService.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 16/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import RxCocoa
import RxSwift

final class YodleeMessageService {

    enum MessageError: LocalizedError {
        case providerIdNotFound
        case generic
    }

    enum Effect: Equatable {
        case openExternal(url: URL)
        case success(providerId: String)
        case closed(reason: String)
        case error(MessageError)
        case none

        var isSuccess: Bool {
            guard case .success = self else {
                return false
            }
            return true
        }

        var isFailure: Bool {
            guard case .error = self else {
                return false
            }
            return true
        }

        var providerId: String? {
            switch self {
            case .success(let providerId):
                return providerId
            default:
                return nil
            }
        }
    }

    let effect: Observable<Effect>

    private let messageHandler: YodleeMessageHandler

    init(messageHandler: YodleeMessageHandler,
         parser: @escaping (DataMessage) -> Effect) {
        self.messageHandler = messageHandler

        effect = messageHandler.receivedMessage
            .map(\.data)
            .map { type -> Effect in
                switch type {
                case .externalLink(let data):
                    guard let url = URL(string: data.url) else {
                        return .none
                    }
                    return .openExternal(url: url)
                case .message(let data):
                    return parser(data)
                }
            }
            .share(replay: 1, scope: .whileConnected)

    }

    /// Enables the monitor of events from the message handler
    func startMonitorEvents() {
        messageHandler.registerForEvents()
    }
}

// MARK: - Yodlee Message Parsing

func yodleeMessageParser(data: DataMessage) -> YodleeMessageService.Effect {
    guard let action = data.action, action == .exit else {
        // handle the case where action is nil but we have a provideAccountId
        if let providerId = data.providerAccountId {
            return .success(providerId: String(providerId))
        }
        return .error(.generic)
    }
    if let status = data.status {
        return parse(status: status, reason: data.reason, providerAccountId: data.providerAccountId)
    } else if let sites = data.sites, !sites.isEmpty {
        if let siteData = sites.first, let siteStatus = siteData.status {
            return parse(status: siteStatus, reason: siteData.reason, providerAccountId: siteData.providerAccountId)
        } else {
            return .error(.generic)
        }
    } else {
        return .error(.generic)
    }
}

private func parse(status: MessageStatus, reason: String?, providerAccountId: Int?) -> YodleeMessageService.Effect {
    guard case .success = status else {
        return .closed(reason: reason ?? "unknown reason")
    }
    guard let providerAccountId = providerAccountId else {
        return .error(.providerIdNotFound)
    }
    return .success(providerId: String(providerAccountId))
}
