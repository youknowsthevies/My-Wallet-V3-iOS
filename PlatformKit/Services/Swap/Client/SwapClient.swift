//
//  SwapClient.swift
//  PlatformKit
//
//  Created by Alex McGregor on 4/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import RxSwift

public protocol SwapActivityClientAPI {
    // TODO: Fetch a single activity from an order ID
    func fetchActivity(from date: Date,
                       fiatCurrency: String,
                       cryptoCurrency: CryptoCurrency,
                       limit: Int) -> Single<[SwapActivityItemEvent]>
    
    func fetchActivity(from date: Date,
                       fiatCurrency: String) -> Single<[SwapActivityItemEvent]>
}

public typealias SwapClientAPI = SwapActivityClientAPI

final class SwapClient: SwapClientAPI {
    
    private enum Parameter {
        static let before = "before"
        static let fiatCurrency = "userFiatCurrency"
        static let cryptoCurrency = "currency"
        static let limit = "limit"
    }
    
    private enum Path {
        static let activity = ["trades"]
    }
    
    // MARK: - Properties
    
    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI
    
    // MARK: - Setup
    
    init(communicator: NetworkCommunicatorAPI = resolve(tag: DIKitContext.retail),
         requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)) {
        self.communicator = communicator
        self.requestBuilder = requestBuilder
    }
    
    // MARK: - SwapActivityClientAPI
    
    func fetchActivity(from date: Date,
                       fiatCurrency: String,
                       cryptoCurrency: CryptoCurrency,
                       limit: Int) -> Single<[SwapActivityItemEvent]> {
        let parameters = [
            URLQueryItem(
                name: Parameter.before,
                value: DateFormatter.iso8601Format.string(from: date)
            ),
            URLQueryItem(
                name: Parameter.cryptoCurrency,
                value: cryptoCurrency.code
            ),
            URLQueryItem(
                name: Parameter.fiatCurrency,
                value: fiatCurrency
            ),
            URLQueryItem(
                name: Parameter.limit,
                value: "\(limit)"
            )
        ]
        let path = Path.activity
        let request = requestBuilder.get(
            path: path,
            parameters: parameters,
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
    func fetchActivity(from date: Date, fiatCurrency: String) -> Single<[SwapActivityItemEvent]> {
        let parameters = [
            URLQueryItem(
                name: Parameter.before,
                value: DateFormatter.iso8601Format.string(from: date)
            ),
            URLQueryItem(
                name: Parameter.fiatCurrency,
                value: fiatCurrency
            )
        ]
        let path = Path.activity
        let request = requestBuilder.get(
            path: path,
            parameters: parameters,
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
}
