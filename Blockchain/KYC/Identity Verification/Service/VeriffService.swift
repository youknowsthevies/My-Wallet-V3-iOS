//
//  VeriffService.swift
//  Blockchain
//
//  Created by Alex McGregor on 1/9/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit
import PlatformKit
import RxSwift

class VeriffService {
    
    private let authService: NabuAuthenticationService
    
    init(authService: NabuAuthenticationService = NabuAuthenticationService.shared) {
        self.authService = authService
    }
    
    // MARK: - Public
    
    /// Creates VeriffCredentials
    func createCredentials() -> Single<(VeriffCredentials)> {
        authService.tokenString.flatMap { token in
            let headers = [HttpHeaderField.authorization: token]
            return KYCNetworkRequest.request(
                get: .credentiasForVeriff,
                headers: headers,
                type: VeriffCredentials.self
            )
        }
    }
    
    /// Submits the Veriff applicantId to Blockchain to complete KYC processing.
    /// This should be invoked upon successfully uploading the identity docs to Veriff.
    ///
    /// - Parameter applicantId: applicantId derived from `VeriffCredentials`
    /// - Returns: a Completable
    func submitVerification(applicantId: String) -> Completable {
        authService.tokenString.flatMapCompletable { token in
            let headers = [HttpHeaderField.authorization: token]
            let payload = [
                "applicantId": applicantId,
                HttpHeaderField.clientType: HttpHeaderValue.clientTypeApp
            ]
            return KYCNetworkRequest.request(
                post: .submitVerification,
                parameters: payload,
                headers: headers
            )
        }
    }
}
