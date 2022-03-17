// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import PlatformKit
import RxSwift

final class ReceiveScreenInteractor {

    struct State {
        let metadata: CryptoAssetQRMetadata
        let domainNames: [String]
        let memo: String?
    }

    let account: SingleAccount
    let resolutionService: BlockchainNameResolutionServiceAPI
    let receiveRouter: ReceiveRouterAPI

    var state: Single<State> {
        account
            .receiveAddress
            .flatMap { [resolutionService] address -> Single<(ReceiveAddress, [String])> in
                resolutionService
                    .reverseResolve(address: address.address)
                    .asSingle()
                    .map { (address, $0) }
            }
            .map { address, domainNames -> State in
                guard let metadataProvider = address as? CryptoAssetQRMetadataProviding else {
                    throw ReceiveAddressError.notSupported
                }
                return State(
                    metadata: metadataProvider.metadata,
                    domainNames: domainNames,
                    memo: address.memo
                )
            }
    }

    init(
        account: SingleAccount,
        resolutionService: BlockchainNameResolutionServiceAPI = resolve(),
        receiveRouter: ReceiveRouterAPI = resolve()
    ) {
        self.account = account
        self.resolutionService = resolutionService
        self.receiveRouter = receiveRouter
    }
}
