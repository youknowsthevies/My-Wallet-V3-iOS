// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import FeatureTransactionDomain
import PlatformKit
import ToolKit

final class ReceiveScreenInteractor {

    private typealias AddressAndDomainsPublisher = AnyPublisher<
        (address: ReceiveAddress, domainNames: [String]),
        Never
    >

    struct State {
        let qrCodeMetadata: QRCodeMetadata
        let domainNames: [String]
        let memo: String?
    }

    let account: SingleAccount
    let resolutionService: BlockchainNameResolutionServiceAPI
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let receiveRouter: ReceiveRouterAPI

    var state: AnyPublisher<State?, Never> {
        account.receiveAddressPublisher
            .flatMap { [resolutionService, analyticsRecorder] receiveAddress -> AddressAndDomainsPublisher in
                resolutionService.reverseResolve(address: receiveAddress.address)
                    .handleEvents(
                        receiveOutput: { [analyticsRecorder] _ in
                            analyticsRecorder.record(
                                event: AnalyticsEvents.New.Receive.receiveDomainReverseResolved
                            )
                        }
                    )
                    .replaceError(with: [])
                    .map { domains in
                        (receiveAddress, domains)
                    }
                    .eraseToAnyPublisher()
            }
            .map { [account] address, domainNames -> State? in
                guard let metadataProvider = address as? QRCodeMetadataProvider else {
                    if BuildFlag.isInternal {
                        fatalError("Account/Currency not supported: \(account.identifier) \(address.currencyType.code)")
                    }
                    return nil
                }
                return State(
                    qrCodeMetadata: metadataProvider.qrCodeMetadata,
                    domainNames: domainNames,
                    memo: address.memo
                )
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
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
