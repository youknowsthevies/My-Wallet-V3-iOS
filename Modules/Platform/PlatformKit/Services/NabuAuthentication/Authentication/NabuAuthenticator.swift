//
//  NabuAuthenticator.swift
//  PlatformKit
//
//  Created by Jack Pooley on 29/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import DIKit
import NetworkKit
import ToolKit

final class NabuAuthenticator: AuthenticatorAPI {
    
    // MARK: - Properties
    
    private var authenticationExecutor: NabuAuthenticationExecutorAPI {
        authenticationExecutorProvider()
    }
    
    private let authenticationExecutorProvider: NabuAuthenticationExecutorProvider
    
    // MARK: - Setup
    
    init(authenticationExecutorProvider: @escaping NabuAuthenticationExecutorProvider = resolve()) {
        self.authenticationExecutorProvider = authenticationExecutorProvider
    }
    
    // MARK: - AuthenticatorNewAPI
    
    func authenticate(
        _ networkResponsePublisher: @escaping NetworkResponsePublisher
    ) -> AnyPublisher<ServerResponse, NetworkCommunicatorError> {
        authenticationExecutor.authenticate(networkResponsePublisher)
    }
}
