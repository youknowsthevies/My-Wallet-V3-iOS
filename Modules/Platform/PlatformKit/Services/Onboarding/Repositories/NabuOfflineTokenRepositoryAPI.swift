//
//  NabuOfflineTokenRepositoryAPI.swift
//  PlatformKit
//
//  Created by Daniel on 26/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import RxSwift

public protocol NabuOfflineTokenRepositoryCombineAPI: AnyObject {
    
    var offlineTokenResponsePublisher: AnyPublisher<NabuOfflineTokenResponse, MissingCredentialsError> { get }
    
    func setPublisher(offlineTokenResponse: NabuOfflineTokenResponse) -> AnyPublisher<Void, CredentialWritingError>
}

public protocol NabuOfflineTokenRepositoryAPI: AnyObject {
    var offlineTokenResponse: Single<NabuOfflineTokenResponse> { get }
    func set(offlineTokenResponse: NabuOfflineTokenResponse) -> Completable
}
