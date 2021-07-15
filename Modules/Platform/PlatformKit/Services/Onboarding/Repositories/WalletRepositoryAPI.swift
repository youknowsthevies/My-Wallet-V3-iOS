// Copyright © Blockchain Luxembourg S.A. All rights reserved.
import AuthenticationKit

public typealias WalletRepositoryAPI = SessionTokenRepositoryAPI
                                     & SharedKeyRepositoryAPI
                                     & PasswordRepositoryAPI
                                     & GuidRepositoryAPI
                                     & SyncPubKeysRepositoryAPI
                                     & LanguageRepositoryAPI
                                     & AuthenticatorRepositoryAPI
                                     & PayloadRepositoryAPI
                                     & NabuOfflineTokenRepositoryAPI
                                     & CredentialsRepositoryAPI

public protocol WalletRepositoryProvider {

    var repository: WalletRepositoryAPI! { get }
}
