// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public typealias WalletRepositoryAPI = SessionTokenRepositoryAPI
                                     & SharedKeyRepositoryAPI
                                     & SharedKeyRepositoryCombineAPI
                                     & PasswordRepositoryAPI
                                     & GuidRepositoryAPI
                                     & SyncPubKeysRepositoryAPI
                                     & LanguageRepositoryAPI
                                     & AuthenticatorRepositoryAPI
                                     & PayloadRepositoryAPI
                                     & NabuOfflineTokenRepositoryAPI
                                     & NabuOfflineTokenRepositoryCombineAPI
                                     & CredentialsRepositoryAPI

public protocol WalletRepositoryProvider {
    
    var repository: WalletRepositoryAPI! { get }
}
