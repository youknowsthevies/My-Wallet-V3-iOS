// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine
import RxSwift

public protocol NabuOfflineTokenRepositoryCombineAPI: AnyObject {

    var offlineTokenResponsePublisher: AnyPublisher<NabuOfflineTokenResponse, MissingCredentialsError> { get }

    func setPublisher(offlineTokenResponse: NabuOfflineTokenResponse) -> AnyPublisher<Void, CredentialWritingError>
}

public protocol NabuOfflineTokenRepositoryAPI: NabuOfflineTokenRepositoryCombineAPI {
    var offlineTokenResponse: Single<NabuOfflineTokenResponse> { get }

    func set(offlineTokenResponse: NabuOfflineTokenResponse) -> Completable
}
