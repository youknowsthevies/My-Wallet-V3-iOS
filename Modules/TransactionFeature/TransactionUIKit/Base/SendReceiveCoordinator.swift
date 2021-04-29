// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import TransactionKit

public class SendReceiveCoordinator {

    // MARK: Public Properties

    public let builder: SendReceiveBuilder

    // MARK: Private Properties

    private let sendRouter: SendRouterAPI
    private let receiveRouter: ReceiveRouterAPI
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(sendRouter: SendRouterAPI = resolve(),
         receiveRouter: ReceiveRouterAPI = resolve(),
         sendSelectionService: AccountSelectionServiceAPI = AccountSelectionService(),
         receiveSelectionService: AccountSelectionServiceAPI = AccountSelectionService()) {
        self.sendRouter = sendRouter
        self.receiveRouter = receiveRouter
        builder = SendReceiveBuilder(
            sendSelectionService: sendSelectionService,
            receiveSelectionService: receiveSelectionService
        )

        receiveSelectionService
            .selectedData
            .subscribe(onNext: { [weak self] account in
                self?.receiveRouter.presentReceiveScreen(for: account)
            })
            .disposed(by: disposeBag)

        sendSelectionService
            .selectedData
            .subscribe(onNext: { [weak self] account in
                self?.sendRouter.send(account: account)
            })
            .disposed(by: disposeBag)
    }
}
