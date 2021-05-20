// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit
import TransactionKit

final class TargetSelectionInteractor {

    private let coincore: Coincore
    private let featureFetcher: FeatureFetching
    private let nameResolutionService: BlockchainNameResolutionServicing

    init(
        coincore: Coincore = resolve(),
        nameResolutionService: BlockchainNameResolutionServicing = resolve(),
        featureFetcher: FeatureFetching = resolve()
    ) {
        self.coincore = coincore
        self.featureFetcher = featureFetcher
        self.nameResolutionService = nameResolutionService
    }

    func getBitPayInvoiceTarget(data: String, asset: CryptoCurrency) -> Single<BitPayInvoiceTarget> {
        BitPayInvoiceTarget.make(from: data, asset: .bitcoin)
    }

    func getAvailableTargetAccounts(sourceAccount: BlockchainAccount,
                                    action: AssetAction) -> Single<[SingleAccount]> {
        Single.just(sourceAccount)
            .map { (account) -> CryptoAccount in
                guard let crypto = account as? CryptoAccount else {
                    fatalError("Expected CryptoAccount: \(account)")
                }
                return crypto
            }
            .flatMap(weak: self) { (self, account) -> Single<[SingleAccount]> in
                self.coincore.getTransactionTargets(sourceAccount: account, action: action)
            }
    }

    func validateCrypto(address: String, account: CryptoAccount) -> Single<Result<ReceiveAddress, Error>> {
        guard let asset = coincore[account.asset] else {
            fatalError("asset for \(account) not found")
        }
        return asset
            .parse(address: address)
            .flatMap(weak: self) { (self, validatedAddress) -> Single<Result<ReceiveAddress, Error>> in
                guard let validatedAddress = validatedAddress else {
                    return self.validate(domainName: address, currency: account.asset)
                }
                return .just(.success(validatedAddress))
            }
    }

    private func validate(domainName: String, currency: CryptoCurrency) -> Single<Result<ReceiveAddress, Error>> {
        featureFetcher.fetchBool(for: .sendToDomainName)
            .flatMap(weak: self) { (self, isEnabled) -> Single<Result<ReceiveAddress, Error>> in
                guard isEnabled else {
                    return .just(.failure(CryptoAssetError.addressParseFailure))
                }
                return self.nameResolutionService
                    .validate(domainName: domainName, currency: currency)
                    .asObservable()
                    .take(1)
                    .asSingle()
                    .map { receiveAddress -> Result<ReceiveAddress, Error> in
                        switch receiveAddress {
                        case .some(let receiveAddress):
                            return .success(receiveAddress)
                        case .none:
                            return .failure(CryptoAssetError.addressParseFailure)
                        }
                    }
            }
    }
}
