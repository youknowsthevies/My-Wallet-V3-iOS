// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineExt
import DIKit
import EthereumKit
import PlatformKit
import RxSwift
import ToolKit

final class ERC20Asset: CryptoAsset {

    // MARK: - Properties

    let asset: CryptoCurrency

    var canTransactToCustodial: AnyPublisher<Bool, Never> {
        cryptoAssetRepository.canTransactToCustodial
    }

    // MARK: - Private properties

    var defaultAccount: AnyPublisher<SingleAccount, CryptoAssetError> {
        walletAccountBridge.defaultAccount(erc20Token: erc20Token)
    }

    // MARK: - Private properties

    private lazy var cryptoAssetRepository: CryptoAssetRepositoryAPI = {
        CryptoAssetRepository(
            asset: asset,
            errorRecorder: errorRecorder,
            kycTiersService: kycTiersService,
            defaultAccountProvider: { [walletAccountBridge, erc20Token] in
                walletAccountBridge.defaultAccount(erc20Token: erc20Token)
            },
            exchangeAccountsProvider: exchangeAccountProvider,
            addressFactory: addressFactory
        )
    }()

    private let addressFactory: ERC20ExternalAssetAddressFactory
    private let erc20Token: ERC20AssetModel
    private let kycTiersService: KYCTiersServiceAPI
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let walletAccountBridge: EthereumWalletAccountRepositoryAPI
    private let errorRecorder: ErrorRecording

    // MARK: - Setup

    init(
        erc20Token: ERC20AssetModel,
        walletAccountBridge: EthereumWalletAccountRepositoryAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        addressFactory: ERC20ExternalAssetAddressFactory = .init()
    ) {
        asset = erc20Token.cryptoCurrency
        self.addressFactory = addressFactory
        self.erc20Token = erc20Token
        self.walletAccountBridge = walletAccountBridge
        self.errorRecorder = errorRecorder
        self.exchangeAccountProvider = exchangeAccountProvider
        self.kycTiersService = kycTiersService
    }

    // MARK: - Asset

    func initialize() -> AnyPublisher<Void, AssetError> {
        Just(())
            .mapError(to: AssetError.self)
            .eraseToAnyPublisher()
    }

    func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup, Never> {
        cryptoAssetRepository.accountGroup(filter: filter)
    }

    func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never> {
        cryptoAssetRepository.parse(address: address)
    }
}

extension EthereumWalletAccountRepositoryAPI {

    fileprivate func defaultAccount(erc20Token: ERC20AssetModel) -> AnyPublisher<SingleAccount, CryptoAssetError> {
        defaultAccount
            .mapError(CryptoAssetError.failedToLoadDefaultAccount)
            .map { account in
                ERC20CryptoAccount(
                    publicKey: account.publicKey,
                    erc20Token: erc20Token
                )
            }
            .eraseToAnyPublisher()
    }
}
