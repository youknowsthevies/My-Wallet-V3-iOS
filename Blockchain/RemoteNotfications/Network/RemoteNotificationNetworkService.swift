//
//  RemoteNotificationNetworkService.swift
//  Blockchain
//
//  Created by Jack on 22/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import NetworkKit
import PlatformKit

/// Remote notification network service
final class RemoteNotificationNetworkService {
    
    // MARK: - Types
    
    enum PushNotificationError: Error {
        case registrationFailure
        case missingCredentials
        case emptyCredentials
        case couldNotBuildRequestBody
    }
    
    private struct RegistrationResponseData: Decodable {
        let success: Bool
    }

    // MARK: - Properties
    
    private let url = BlockchainAPI.shared.pushNotificationsUrl
    private let communicator: NetworkCommunicatorAPI
    
    // MARK: - Setup
    
    init(communicator: NetworkCommunicatorAPI = NetworkCommunicator.shared) {
        self.communicator = communicator
    }
}

// MARK: - RemoteNotificationNetworkServicing

extension RemoteNotificationNetworkService: RemoteNotificationNetworkServicing {

    func register(with token: String,
                  using credentialsProvider: SharedKeyRepositoryAPI & GuidRepositoryAPI) -> Single<Void> {
        registrationRequest(with: token, using: credentialsProvider)
            .flatMap(weak: self) { (self, request) -> Single<RegistrationResponseData> in
                self.communicator.perform(request: request)
            }
            .map { response -> Void in
                guard response.success
                    else { throw PushNotificationError.registrationFailure }
                return ()
            }
    }

    private func registrationRequest(with token: String,
                                     using credentialsProvider: SharedKeyRepositoryAPI & GuidRepositoryAPI) -> Single<NetworkRequest> {
        Single
            .zip(
                credentialsProvider.sharedKey,
                credentialsProvider.guid
            )
            .map { credentials -> RemoteNotificationTokenQueryParametersBuilder in
                guard let guid: String = credentials.1, let sharedKey: String = credentials.0 else {
                    throw PushNotificationError.missingCredentials
                }
                guard !guid.isEmpty, !sharedKey.isEmpty else {
                    throw PushNotificationError.emptyCredentials
                }
                let builder = try RemoteNotificationTokenQueryParametersBuilder(guid: guid, sharedKey: sharedKey, token: token)
                return builder
            }
            .map { builder -> Data in
                guard let parameters = builder.parameters else {
                    throw PushNotificationError.couldNotBuildRequestBody
                }
                return parameters
            }
            .map(weak: self) { (self, body) -> NetworkRequest in
                let url = URL(string: self.url)!
                return NetworkRequest(
                    endpoint: url,
                    method: .post,
                    body: body,
                    contentType: .formUrlEncoded
                )
            }
    }
}
