// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import TransactionKit

public class ReceiveCoordinator {

    // MARK: Public Properties

    public let builder: ReceiveBuilder

    // MARK: Private Properties

    private let receiveRouter: ReceiveRouterAPI
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(receiveRouter: ReceiveRouterAPI = resolve(),
         receiveSelectionService: AccountSelectionServiceAPI = AccountSelectionService()) {
        self.receiveRouter = receiveRouter
        builder = ReceiveBuilder(
            receiveSelectionService: receiveSelectionService
        )

        receiveSelectionService
            .selectedData
            .subscribe(onNext: { [weak self] account in
                self?.receiveRouter.presentReceiveScreen(for: account)
            })
            .disposed(by: disposeBag)
    }
}
