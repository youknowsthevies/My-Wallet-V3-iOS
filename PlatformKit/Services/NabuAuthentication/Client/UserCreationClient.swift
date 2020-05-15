//
//  UserCreationClient.swift
//  PlatformKit
//
//  Created by Daniel Huri on 13/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import NetworkKit

public struct CreateUserResponse: Decodable {
    public let userId: String
    public let token: String
    
    public init(userId: String, token: String) {
        self.userId = userId
        self.token = token
    }
}

public protocol UserCreationClientAPI: class {
    func createUser(for token: String) -> Single<CreateUserResponse>
}

public final class UserCreationClient: UserCreationClientAPI {
    
    // MARK: - Types

    private enum Parameter: String {
        case jwt
    }
    
    private enum Path {
        static let users = [ "users" ]
    }
    
    // MARK: - Properties
    
    private let requestBuilder: RequestBuilder
    private let communicator: NetworkCommunicatorAPI

    // MARK: - Setup
    
    public init(dependencies: Network.Dependencies = .retail) {
        self.communicator = dependencies.communicator
        self.requestBuilder = RequestBuilder(networkConfig: dependencies.blockchainAPIConfig)
    }
        
    public func createUser(for token: String) -> Single<CreateUserResponse> {
        struct Payload: Encodable {
            let jwt: String
        }
        
        let payload = Payload(jwt: token)
        let request = requestBuilder.post(
            path: Path.users,
            body: try? payload.encode()
        )!
        return communicator.perform(request: request)
    }
}
