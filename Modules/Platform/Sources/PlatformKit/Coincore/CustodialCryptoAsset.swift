// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import RxSwift
import ToolKit

final class CustodialCryptoAsset: CryptoAsset {

    var defaultAccount: AnyPublisher<SingleAccount, CryptoAssetError> {
        .failure(.noDefaultAccount)
    }

    let asset: CryptoCurrency

    var canTransactToCustodial: AnyPublisher<Bool, Never> {
        cryptoAssetRepository.canTransactToCustodial
    }

    // MARK: - Private properties

    private lazy var cryptoAssetRepository: CryptoAssetRepositoryAPI = CryptoAssetRepository(
        asset: asset,
        errorRecorder: errorRecorder,
        kycTiersService: kycTiersService,
        defaultAccountProvider: { [defaultAccount] in
            defaultAccount
        },
        exchangeAccountsProvider: exchangeAccountProvider,
        addressFactory: addressFactory
    )

    private let kycTiersService: KYCTiersServiceAPI
    private let errorRecorder: ErrorRecording
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let addressFactory: ExternalAssetAddressFactory
    private let featureFetcher: FeatureFetching
    private let nabuUserService: NabuUserServiceAPI

    // MARK: - Setup

    init(
        asset: CryptoCurrency,
        exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        featureFetcher: FeatureFetching = resolve(),
        nabuUserService: NabuUserServiceAPI = resolve()
    ) {
        self.asset = asset
        self.kycTiersService = kycTiersService
        self.exchangeAccountProvider = exchangeAccountProvider
        self.errorRecorder = errorRecorder
        self.featureFetcher = featureFetcher
        self.nabuUserService = nabuUserService
        addressFactory = PlainCryptoReceiveAddressFactory(asset: asset)
    }

    // MARK: - Asset

    func initialize() -> AnyPublisher<Void, AssetError> {
        Just(())
            .mapError(to: AssetError.self)
            .eraseToAnyPublisher()
    }

    func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup, Never> {
        switch filter {
        case .all:
            return allAccountsGroup
        case .custodial:
            return custodialGroup
        case .interest:
            return interestGroup
        case .nonCustodial:
            return nonCustodialGroup
        case .exchange:
            return exchangeGroup
        }
    }

    func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never> {
        addressFactory
            .makeExternalAssetAddress(
                address: address,
                label: address,
                onTxCompleted: { _ in .empty() }
            )
            .publisher
            .map { address -> ReceiveAddress? in
                address
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    func parse(
        address: String,
        label: String,
        onTxCompleted: @escaping (TransactionResult) -> Completable
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        addressFactory.makeExternalAssetAddress(
            address: address,
            label: label,
            onTxCompleted: onTxCompleted
        )
    }

    private var allAccountsGroup: AnyPublisher<AccountGroup, Never> {
        [
            nonCustodialGroup,
            custodialGroup,
            interestGroup,
            exchangeGroup
        ]
        .zip()
        .eraseToAnyPublisher()
        .flatMapAllAccountGroup()
    }

    private var exchangeGroup: AnyPublisher<AccountGroup, Never> {
        cryptoAssetRepository.exchangeGroup
    }

    private var custodialGroup: AnyPublisher<AccountGroup, Never> {
        cryptoAssetRepository.custodialGroup
    }

    private var interestGroup: AnyPublisher<AccountGroup, Never> {
        cryptoAssetRepository.interestGroup
    }

    private var nonCustodialGroup: AnyPublisher<AccountGroup, Never> {
        dynamicSelfCustodySupported
            .map { [asset] isEnabled in
                guard isEnabled else {
                    return CryptoAccountNonCustodialGroup(
                        asset: asset,
                        accounts: []
                    )
                }
                let account = CryptoDelegatedCustodyAccount(
                    asset: asset,
                    balanceRepository: resolve(),
                    featureFlagsService: resolve(),
                    priceService: resolve()
                )
                return CryptoAccountNonCustodialGroup(
                    asset: asset,
                    accounts: [account]
                )
            }
            .eraseToAnyPublisher()
    }

    private var dynamicSelfCustodySupported: AnyPublisher<Bool, Never> {
        // Initially only possible for Stacks.
        guard asset.code == "STX" else {
            return .just(false)
        }
        return Publishers.Zip3(
            featureFetcher.isEnabled(.stxForAllUsers),
            featureFetcher.isEnabled(.stxForAirdropUsers),
            stxAirdropRegistered
        )
        .map { stxForAllUsers, stxForAirdropUsers, stxAirdropRegistered in
            // Enabled if 'All' feature flag is one
            stxForAllUsers
                // Or if 'Airdrop' feature flag is on and user is registered.
                || (stxForAirdropUsers && stxAirdropRegistered)
        }
        .eraseToAnyPublisher()
    }

    private var stxAirdropRegistered: AnyPublisher<Bool, Never> {
        nabuUserService.user
            .map(\.isBlockstackAirdropRegistered)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
