// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public final class SessionTokenService: SessionTokenServiceAPI {
        
    // MARK: - Injected
    
    private let client: SessionTokenClientAPI
    private let repository: SessionTokenRepositoryAPI
    
    // MARK: - Setup
    
    public init(client: SessionTokenClientAPI = SessionTokenClient(), repository: SessionTokenRepositoryAPI) {
        self.client = client
        self.repository = repository
    }
    
    /// Requests a session token for the wallet, if not available already
    /// and assign it to the repository.
    public func setupSessionToken() -> Completable {
        repository.hasSessionToken
            .flatMapCompletable(weak: self) { (self, hasSessionToken) -> Completable in
                guard !hasSessionToken else {
                    return .empty()
                }
                return self.client.token
                    .flatMapCompletable(weak: self) { (self, sessionToken) -> Completable in
                        self.repository.set(sessionToken: sessionToken)
                    }
                }
    }
}
