// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureTransactionDomain
import PlatformKit
import RxSwift

final class ReceiveScreenInteractor {

    struct State {
        let qrCodeMetadata: QRCodeMetadata
        let domainNames: [String]
        let memo: String?
    }

    let account: SingleAccount
    let resolutionService: BlockchainNameResolutionServiceAPI
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let receiveRouter: ReceiveRouterAPI

    var state: Single<State> {
        account
            .receiveAddress
            .flatMap { [resolutionService] receiveAddress -> Single<(ReceiveAddress, [String])> in
                resolutionService
                    .reverseResolve(address: receiveAddress.address)
                    .map { (receiveAddress, $0) }
                    .handleEvents(receiveOutput: { [weak self] _ in
                        self?.analyticsRecorder.record(event: AnalyticsEvents.New.Receive.receiveDomainReverseResolved)
                    })
                    .asSingle()
            }
            .map { address, domainNames -> State in
                guard let metadataProvider = address as? QRCodeMetadataProvider else {
                    throw ReceiveAddressError.notSupported
                }
                return State(
                    qrCodeMetadata: metadataProvider.qrCodeMetadata,
                    domainNames: domainNames,
                    memo: address.memo
                )
            }
    }

    init(
        account: SingleAccount,
        resolutionService: BlockchainNameResolutionServiceAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        receiveRouter: ReceiveRouterAPI = resolve()
    ) {
        self.account = account
        self.resolutionService = resolutionService
        self.analyticsRecorder = analyticsRecorder
        self.receiveRouter = receiveRouter
    }
}
