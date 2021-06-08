// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

extension WalletManager: WalletManagerReactiveAPI {
    // MARK: WalletAuthDelegate

    /// Reactive wrapper for delegate method `walletDidDecrypt(withSharedKey:guid:)`
    /// - Note: Returns a `WalletDecryption` instance containing info as received from the delegate method
    var didDecryptWallet: AnyPublisher<WalletDecryption, Error> {
        self.rx.didDecryptWallet
            .asPublisher()
    }
    
    /// Reactive wrapper for authentication delegate methods
    /// - Note: The following methods will be taken into account and will create a `Result<Bool, AuthenticationError>`:
    /// - `walletDidFinishLoad`
    /// - `walletFailedToLoad`
    /// - `walletFailedToDecrypt`
    var didCompleteAuthentication: AnyPublisher<Result<Bool, AuthenticationError>, Never> {
        self.rx.didCompleteAuthentication
            .asPublisher()
            .ignoreFailure()
    }
    
    // MARK: WalletAccountInfoDelegate

    /// Reactive wrapper for delegate method `walletDidGetAccountInfo`
    /// - Note: Invoked when the account info has been retrieved
    var didGetAccountInfo: AnyPublisher<Void, Error> {
        self.rx.didGetAccountInfo
            .asPublisher()
            .mapToVoid()
    }

    // MARK: WalletAddressesDelegate

    /// Reactive wrapper for delegate method `didGenerateNewAddress`
    /// - Note: Method invoked when generating a new address (V2/legacy wallet only)
    var newAddressGenerated: AnyPublisher<Void, Error> {
        self.rx.didGenerateNewAddress
            .asPublisher()
            .mapToVoid()
    }

    /// Reactive wrapper for delegate method `returnToAddressesScreen`
    /// - Note: Method invoked when finding a null account or address when checking if archived
    var shouldReturnToAddressesScreen: AnyPublisher<Void, Error> {
        self.rx.returnToAddressesScreen
            .asPublisher()
            .mapToVoid()
    }

    /// Reactive wrapper for delegate method `didSetDefaultAccount`
    /// - Note: Method invoked when the default account for an asset has been changed
    var defaultAccountSet: AnyPublisher<Void, Error> {
        self.rx.didSetDefaultAccount
            .asPublisher()
            .mapToVoid()
    }

    // MARK: WalletRecoveryDelegate

    /// Reactive wrapper for delegate method `didRecoverWallet`
    /// - Note:  Method invoked when the recovery sequence is completed
    var walletRecovered: AnyPublisher<Void, Error> {
        self.rx.didRecoverWallet
            .asPublisher()
            .mapToVoid()
    }

    /// Reactive wrapper for delegate method `didFailRecovery`
    /// - Note:  Method invoked when the recovery sequence fails to complete
    var walletRecoveryFailed: AnyPublisher<Void, Error> {
        self.rx.didFailRecovery
            .asPublisher()
            .mapToVoid()
    }

    // MARK: WalletHistoryDelegate

    /// Reactive wrapper for delegate method `didFailGetHistory`
    /// - Note:  Method invoked when the recovery sequence fails to complete
    var walletFailedToGetHistory: AnyPublisher<String?, Error> {
        self.rx.didFailGetHistory
            .asPublisher()
    }

    // MARK: WalletAccountInfoAndExchangeRatesDelegate

    /// Reactive wrapper for delegate method `walletDidGetAccountInfoAndExchangeRates`
    /// - Note: Method invoked after getting account info and exchange rates on startup
    var walletDidGetAccountInfoAndExchangeRates: AnyPublisher<Void, Error> {
        self.rx.didGetAccountInfoAndExchangeRates
            .asPublisher()
            .mapToVoid()
    }

    // MARK: WalletBackupDelegate

    /// Reactive wrapper for delegate method `didBackupWallet`
    /// - Note: Method invoked when backup sequence is completed
    var walletBackupSuccess: AnyPublisher<Void, Error> {
        self.rx.didBackupWallet
            .asPublisher()
            .mapToVoid()
    }

    /// Reactive wrapper for delegate method `didFailBackupWallet`
    /// - Note: Method invoked when backup sequence is completed
    var walletBackupFailed: AnyPublisher<Void, Error> {
        self.rx.didFailBackupWallet
            .asPublisher()
            .mapToVoid()
    }

    // MARK: WalletTransactionDelegate

    /// Reactive wrapper for delegate method `onTransactionReceived`
    /// - Note: Method invoked when a transaction is received (only invoked when there is an
    /// active websocket connection when the transaction was received)
    var walletOnTransactionReceived: AnyPublisher<Void, Error> {
        self.rx.onTransactionReceived
            .asPublisher()
            .mapToVoid()
    }

    // MARK: WalletSwipeAddressDelegate

    /// Reactive wrapper for delegate method `onRetrievedSwipeToReceive`
    /// Method invoked when swipe to receive addresses has been retrieved.
    ///
    /// - Parameters:
    ///   - addresses: the addresses
    ///   - assetType: the type of the asset for the retrieved addresses
    var walletOnRetrievedSwipeToReceive: AnyPublisher<(addresses: [String], assetType: CryptoCurrency), Error> {
        self.rx.onRetrievedSwipeToReceive
            .asPublisher()
    }

    // MARK: WalletSecondPasswordDelegate

    /// Reactive wrapper for delegate method `getSecondPassword`
    /// - Note: Method invoked when second password is required for JS function to complete.
    var getSecondPassword: AnyPublisher<(success: WalletSuccessCallback, dismiss: WalletDismissCallback?), Error> {
        self.rx.getSecondPassword
            .asPublisher()
    }

    var getPrivateKeyPassword: AnyPublisher<WalletSuccessCallback, Error> {
        self.rx.getPrivateKeyPassword
            .asPublisher()
    }
}
