// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit
import PlatformKit
import RxSwift
import ToolKit

final class ERC20Asset: CryptoAsset {

    let asset: CryptoCurrency

    var defaultAccount: Single<SingleAccount> {
        walletAccountBridge.wallets
            .map { $0.first }
            .map { wallet -> EthereumWalletAccount in
                guard let wallet = wallet else {
                    throw CryptoAssetError.noDefaultAccount
                }
                return wallet
            }
            .map { [erc20Token] wallet -> SingleAccount in
                ERC20CryptoAccount(publicKey: wallet.publicKey, erc20Token: erc20Token)
            }
    }

    let kycTiersService: KYCTiersServiceAPI
    private let addressFactory: ERC20ExternalAssetAddressFactory
    private let erc20Token: ERC20AssetModel
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let walletAccountBridge: EthereumWalletAccountBridgeAPI
    private let errorRecorder: ErrorRecording

    init(
        erc20Token: ERC20AssetModel,
        walletAccountBridge: EthereumWalletAccountBridgeAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        addressFactory: ERC20ExternalAssetAddressFactory = .init()
    ) {
        self.asset = erc20Token.cryptoCurrency
        self.addressFactory = addressFactory
        self.erc20Token = erc20Token
        self.walletAccountBridge = walletAccountBridge
        self.errorRecorder = errorRecorder
        self.exchangeAccountProvider = exchangeAccountProvider
        self.kycTiersService = kycTiersService
    }

    func accountGroup(filter: AssetFilter) -> Single<AccountGroup> {
        switch filter {
        case .all:
            return allAccountsGroup
        case .custodial:
            return custodialGroup
        case .interest:
            return interestGroup
        case .nonCustodial:
            return nonCustodialGroup
        }
    }

    func parse(address: String) -> Single<ReceiveAddress?> {
        let receiveAddress = try? addressFactory
            .makeExternalAssetAddress(
                asset: asset,
                address: address,
                label: address,
                onTxCompleted: { _ in Completable.empty() }
            )
            .get()
        return .just(receiveAddress)
    }

    // MARK: - Helpers

    private var allAccountsGroup: Single<AccountGroup> {
        Single
            .zip([
                nonCustodialGroup,
                custodialGroup,
                interestGroup,
                exchangeGroup
            ])
            .flatMapAllAccountGroup()
    }

    private var custodialGroup: Single<AccountGroup> {
        .just(
            CryptoAccountCustodialGroup(asset: asset, account: CryptoTradingAccount(asset: asset))
        )
    }

    private var interestGroup: Single<AccountGroup> {
        guard isLegacyERC20 else {
            return .just(CryptoAccountCustodialGroup(asset: asset))
        }
        return .just(
            CryptoAccountCustodialGroup(asset: asset, account: CryptoInterestAccount(asset: asset))
        )
    }

    /// Helper to decided if we should support custodial Accounts.
    /// In the future this should use the `AssetModel.products` field to make this decision.
    private lazy var isLegacyERC20: Bool = {
        LegacyERC20Code.allCases.map(\.rawValue).contains(asset.code)
    }()

    private var exchangeGroup: Single<AccountGroup> {
        guard isLegacyERC20 else {
            return .just(CryptoAccountCustodialGroup(asset: asset))
        }
        return exchangeAccountProvider
            .account(for: asset)
            .optional()
            .catchError { error in
                /// TODO: This shouldn't prevent users from seeing all accounts.
                /// Potentially return nil should this fail.
                guard let serviceError = error as? ExchangeAccountsNetworkError else {
                    #if INTERNAL_BUILD
                    Logger.shared.error(error)
                    throw error
                    #else
                    return Single.just(nil)
                    #endif
                }
                switch serviceError {
                case .missingAccount:
                    return Single.just(nil)
                }
            }
            .map { [asset] account in
                guard let account = account else {
                    return CryptoAccountCustodialGroup(asset: asset)
                }
                return CryptoAccountCustodialGroup(asset: asset, account: account)
            }
    }

    private var nonCustodialGroup: Single<AccountGroup> {
        walletAccountBridge.wallets
            .map { [erc20Token] wallets -> [SingleAccount] in
                wallets.map { ERC20CryptoAccount(publicKey: $0.publicKey, erc20Token: erc20Token) }
            }
            .map { [asset] accounts -> AccountGroup in
                CryptoAccountNonCustodialGroup(asset: asset, accounts: accounts)
            }
            .recordErrors(on: errorRecorder)
            .catchErrorJustReturn(CryptoAccountNonCustodialGroup(asset: asset, accounts: []))
    }
}
