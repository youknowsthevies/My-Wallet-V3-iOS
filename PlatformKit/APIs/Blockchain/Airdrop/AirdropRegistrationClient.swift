//
//  AirdropRegistrationClient.swift
//  PlatformKit
//
//  Created by Jack on 25/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import NetworkKit
import RxSwift
import ToolKit

protocol AirdropRegistrationClientAPI {

    func submitRegistrationRequest(_ registrationRequest: AirdropRegistrationRequest) -> Single<AirdropRegistrationResponse>
}

final class AirdropRegistrationClient: AirdropRegistrationClientAPI {

    // MARK: - Types

    struct Endpoint {
        static let airdropRegistration = [ "nabu-gateway", "users", "register-campaign" ]
    }

    /// An internal model used when registering a `publicKey` for an asset
    /// that will be Airdropped
    private struct Payload: Codable {
        static let campaignKey: String = "x-campaign-address"

        let data: [String: String]
        let newUser: Bool

        init(publicKey: String, isNewUser: Bool) {
            self.data = [Payload.campaignKey: publicKey]
            self.newUser = isNewUser
        }
    }

    // MARK: - Private properties

    private let communicator: NetworkCommunicatorAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Init

    init(communicator: NetworkCommunicatorAPI = Network.Dependencies.default.communicator,
         requestBuilder: RequestBuilder = RequestBuilder(networkConfig: Network.Dependencies.default.blockchainAPIConfig)) {
        self.communicator = communicator
        self.requestBuilder = requestBuilder
    }

    // MARK: - APIClientAPI

    func submitRegistrationRequest(_ registrationRequest: AirdropRegistrationRequest) -> Single<AirdropRegistrationResponse> {
        let payload = Payload(
            publicKey: registrationRequest.publicKey,
            isNewUser: registrationRequest.newUser
        )
        let data = try? JSONEncoder().encode(payload)

        let headers: HTTPHeaders = [
            HttpHeaderField.airdropCampaign: registrationRequest.campaignIdentifier
        ]

        guard let request = requestBuilder.put(path: Endpoint.airdropRegistration,
                                               body: data,
                                               headers: headers,
                                               authenticated: true) else {
            return .error(NetworkRequest.NetworkError.generic)
        }
        return communicator.perform(request: request)
    }
}
