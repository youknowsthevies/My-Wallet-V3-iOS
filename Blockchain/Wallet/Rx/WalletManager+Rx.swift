// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import RxCocoa
import RxSwift

extension Reactive where Base: WalletManager {

    // MARK: WalletAuthDelegate

    /// Reactive wrapper for delegate method `walletDidDecrypt(withSharedKey:guid:)`
    /// - Note: Returns a `WalletDecryption` instance containing info as received from the delegate method
    var didDecryptWallet: Observable<WalletDecryption> {
        base.rx.methodInvoked(#selector(WalletManager.walletDidDecrypt(withSharedKey:guid:)))
            .map { arg in
                let sharedKey = try castOrThrow(String?.self, arg[0])
                let guid = try castOrThrow(String?.self, arg[1])
                let passwordPartHash = base.legacyRepository.legacyPassword?.passwordPartHash
                return WalletDecryption(guid: guid, sharedKey: sharedKey, passwordPartHash: passwordPartHash)
            }
            .observeOn(MainScheduler.asyncInstance)
            .share(replay: 1, scope: .whileConnected)
    }

    /// Reactive wrapper for authentication delegate methods
    /// - Note: The following methods will be taken into account and will create a `Result<Bool, AuthenticationError>`:
    /// - `walletDidFinishLoad`
    /// - `walletFailedToLoad`
    /// - `walletFailedToDecrypt`
    var didCompleteAuthentication: Observable<Result<Bool, AuthenticationError>> {
        let success = base.rx.methodInvoked(#selector(WalletManager.walletDidFinishLoad))
            .map { _ in Result<Bool, AuthenticationError>.success(true) }

        let loadError = base.rx.methodInvoked(#selector(WalletManager.walletFailedToLoad))
            .map { _ -> Result<Bool, AuthenticationError> in
                .failure(
                    .init(code: AuthenticationError.ErrorCode.errorDecryptingWallet)
                )
            }

        let decryptError = base.rx.methodInvoked(#selector(WalletManager.walletFailedToDecrypt))
            .map { _ -> Result<Bool, AuthenticationError> in
                .failure(
                    .init(code: AuthenticationError.ErrorCode.failedToLoadWallet)
                )
            }

        return Observable<Result<Bool, AuthenticationError>>
            .merge(success, decryptError, loadError)
            .catchError { error -> Observable<Result<Bool, AuthenticationError>> in
                return .just(
                    .failure(
                        AuthenticationError(
                            code: AuthenticationError.ErrorCode.unknown,
                            description: error.localizedDescription
                        )
                    )
                )
            }
            .observeOn(MainScheduler.asyncInstance)
            .share(replay: 1, scope: .whileConnected)
    }

    // MARK: WalletAccountInfoDelegate

    /// Reactive wrapper for delegate method `walletDidGetAccountInfo`
    /// - Note: Invoked when the account info has been retrieved
    var didGetAccountInfo: Completable {
        base.rx.methodInvoked(#selector(WalletManager.walletDidGetAccountInfo))
            .ignoreElements()
            .observeOn(MainScheduler.asyncInstance)
    }

    // MARK: WalletAddressesDelegate

    /// Reactive wrapper for delegate method `didGenerateNewAddress`
    /// - Note: Method invoked when generating a new address (V2/legacy wallet only)
    var didGenerateNewAddress: Completable {
        base.rx.methodInvoked(#selector(WalletManager.didGenerateNewAddress))
            .ignoreElements()
            .observeOn(MainScheduler.asyncInstance)
    }

    /// Reactive wrapper for delegate method `returnToAddressesScreen`
    /// - Note: Method invoked when finding a null account or address when checking if archived
    var returnToAddressesScreen: Completable {
        base.rx.methodInvoked(#selector(WalletManager.returnToAddressesScreen))
            .ignoreElements()
            .observeOn(MainScheduler.asyncInstance)
    }

    /// Reactive wrapper for delegate method `didSetDefaultAccount`
    /// - Note: Method invoked when the default account for an asset has been changed
    var didSetDefaultAccount: Completable {
        base.rx.methodInvoked(#selector(WalletManager.didSetDefaultAccount))
            .ignoreElements()
            .observeOn(MainScheduler.asyncInstance)
    }

    // MARK: WalletRecoveryDelegate

    /// Reactive wrapper for delegate method `didRecoverWallet`
    /// - Note:  Method invoked when the recovery sequence is completed
    var didRecoverWallet: Completable {
        base.rx.methodInvoked(#selector(WalletManager.didRecoverWallet))
            .ignoreElements()
            .observeOn(MainScheduler.asyncInstance)
    }

    /// Reactive wrapper for delegate method `didFailRecovery`
    /// - Note:  Method invoked when the recovery sequence fails to complete
    var didFailRecovery: Completable {
        base.rx.methodInvoked(#selector(WalletManager.didFailRecovery))
            .ignoreElements()
            .observeOn(MainScheduler.asyncInstance)
    }

    // MARK: WalletHistoryDelegate

    /// Reactive wrapper for delegate method `didFailGetHistory`
    /// - Note:  Method invoked when the recovery sequence fails to complete
    var didFailGetHistory: Observable<String?> {
        base.rx.methodInvoked(#selector(WalletManager.didFailGetHistory(_:)))
            .map { arg in
                let error = try castOrThrow(String?.self, arg[0])
                return error
            }
            .observeOn(MainScheduler.asyncInstance)
            .share(replay: 1, scope: .whileConnected)
    }

    // MARK: WalletAccountInfoAndExchangeRatesDelegate

    /// Reactive wrapper for delegate method `walletDidGetAccountInfoAndExchangeRates`
    /// - Note: Method invoked after getting account info and exchange rates on startup
    var didGetAccountInfoAndExchangeRates: Completable {
        base.rx.methodInvoked(#selector(WalletManager.walletDidGetAccountInfoAndExchangeRates(_:)))
            .ignoreElements()
            .observeOn(MainScheduler.asyncInstance)
    }

    // MARK: WalletBackupDelegate

    /// Reactive wrapper for delegate method `didBackupWallet`
    /// - Note: Method invoked when backup sequence is completed
    var didBackupWallet: Completable {
        base.rx.methodInvoked(#selector(WalletManager.didBackupWallet))
            .ignoreElements()
            .observeOn(MainScheduler.asyncInstance)
    }

    /// Reactive wrapper for delegate method `didFailBackupWallet`
    /// - Note: Method invoked when backup sequence is completed
    var didFailBackupWallet: Completable {
        base.rx.methodInvoked(#selector(WalletManager.didFailBackupWallet))
            .ignoreElements()
            .observeOn(MainScheduler.asyncInstance)
    }

    // MARK: WalletSecondPasswordDelegate

    /// Reactive wrapper for delegate method `getSecondPassword`
    /// - Note: Method invoked when second password is required for JS function to complete.
    var getSecondPassword: Observable<(success: WalletSuccessCallback, dismiss: WalletDismissCallback?)> {
        base.rx.methodInvoked(#selector(WalletManager.getSecondPassword(withSuccess:dismiss:)))
            .map { arg in
                let success = try castOrThrow(WalletSuccessCallback.self, arg[0])
                let dismiss = try castOrThrow(WalletDismissCallback?.self, arg[1])
                return (success, dismiss)
            }
            .observeOn(MainScheduler.asyncInstance)
            .share(replay: 1, scope: .whileConnected)
    }

    var getPrivateKeyPassword: Observable<WalletSuccessCallback> {
        base.rx.methodInvoked(#selector(WalletManager.getSecondPassword(withSuccess:dismiss:)))
            .map { arg in
                let success = try castOrThrow(WalletSuccessCallback.self, arg[0])
                return success
            }
            .observeOn(MainScheduler.asyncInstance)
            .share(replay: 1, scope: .whileConnected)
    }
}

private func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}
