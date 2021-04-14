//
//  NabuAuthenticator.swift
//  PlatformKit
//
//  Created by Daniel on 26/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import RxSwift
import ToolKit

final class NabuAuthenticator: AuthenticatorAPI {
    
    private let authenticationExecutorProvider: NabuAuthenticationExecutorProvider
    private var authenticationExecutor: NabuAuthenticationExecutorAPI {
        authenticationExecutorProvider()
    }

    init(authenticationExecutorProvider: @escaping NabuAuthenticationExecutorProvider = resolve()) {
        self.authenticationExecutorProvider = authenticationExecutorProvider
    }
    
    func authenticate<Response>(_ singleFunction: @escaping (String) -> Single<Response>) -> Single<Response> {
        authenticationExecutor.authenticate(singleFunction: singleFunction)
    }
    
    @available(*, deprecated, message: "This is deprecated. Don't use this.")
    func authenticateWithResult<ResponseType: Decodable, ErrorResponseType: Error & Decodable>(
        _ singleFunction: @escaping (String) -> Single<Result<ResponseType, ErrorResponseType>>
    ) -> Single<Result<ResponseType, ErrorResponseType>> {
        let mappedSingle: (String) -> Single<ResponseType> = { token in
            singleFunction(token).flatMap(\.single)
        }
        return authenticationExecutor
            .authenticate(singleFunction: mappedSingle)
            .map { response -> Result<ResponseType, ErrorResponseType> in
                .success(response)
            }
            .catchError { error -> Single<Result<ResponseType, ErrorResponseType>> in
                guard let mappedError = error as? ErrorResponseType else {
                    throw error
                }
                return .just(.failure(mappedError))
            }
    }
}
