//
//  AuthenticatorAPI.swift
//  NetworkKit
//
//  Created by Jack Pooley on 29/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine

public typealias NetworkResponsePublisher =
    (String) -> AnyPublisher<ServerResponse, NetworkCommunicatorError>

public protocol AuthenticatorAPI: AnyObject {
    
    /// Fetches authentication token
    /// - Parameter responseProvider: method requiring authentication token
    func authenticate(
        _ responseProvider: @escaping NetworkResponsePublisher
    ) -> AnyPublisher<ServerResponse, NetworkCommunicatorError>
}
