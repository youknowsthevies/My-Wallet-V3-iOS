//
//  InformationClient.swift
//  Blockchain
//
//  Created by Daniel Huri on 15/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import NetworkKit

public protocol GeneralInformationClientAPI: AnyObject {
    var countries: Single<[CountryData]> { get }
}

public final class GeneralInformationClient: GeneralInformationClientAPI {
    
    // MARK: - Types
    
    private enum Path {
        static let countries = [ "countries" ]
    }
    
    // MARK: - Properties

    /// Requests a session token for the wallet, if not available already
    public var countries: Single<[CountryData]> {
        let request = requestBuilder.get(
            path: Path.countries
        )!
        return communicator.perform(
            request: request,
            responseType: [CountryData].self
        )
    }
    
    // MARK: - Properties
    
    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI

    // MARK: - Setup
    
    public init(dependencies: Network.Dependencies = .retail) {
        self.communicator = dependencies.communicator
        self.requestBuilder = RequestBuilder(networkConfig: dependencies.blockchainAPIConfig)
    }
}
