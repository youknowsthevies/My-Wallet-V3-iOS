//
//  SendReceiveSegmentedViewScreenPresenter.swift
//  TransactionUIKit
//
//  Created by Paulo on 03/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit
import TransactionKit

public final class SendReceiveSegmentedViewScreenPresenter: SegmentedViewScreenPresenting {

    // MARK: Public Properties

    public let leadingButton: Screen.Style.LeadingButton = .drawer
    public let leadingButtonTapRelay: PublishRelay<Void> = .init()

    public let trailingButton: Screen.Style.TrailingButton = .none
    public let trailingButtonTapRelay: PublishRelay<Void> = .init()

    public let barStyle: Screen.Style.Bar = .lightContent()

    private(set) public lazy var segmentedViewModel: SegmentedViewModel = createSegmentedViewModel()

    private(set) public lazy var items: [SegmentedViewScreenItem] = segmentedItemsFactory.createItems()

    public let itemIndexSelectedRelay: BehaviorRelay<Int?> = .init(value: nil)

    // MARK: Private Properties

    private let drawerRouter: DrawerRouting
    private let sendRouter: SendRouterAPI
    private let receiveRouter: ReceiveRouterAPI
    private let segmentedItemsFactory: SendReceiveSegmentedItemsFactory
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(sendRouter: SendRouterAPI = resolve(),
                drawerRouter: DrawerRouting = resolve(),
                receiveRouter: ReceiveRouterAPI = resolve(),
                sendSelectionService: AccountSelectionServiceAPI = AccountSelectionService(),
                receiveSelectionService: AccountSelectionServiceAPI = AccountSelectionService()) {
        self.drawerRouter = drawerRouter
        self.sendRouter = sendRouter
        self.receiveRouter = receiveRouter
        let builder = SendReceiveBuilder(
            sendSelectionService: sendSelectionService,
            receiveSelectionService: receiveSelectionService
        )
        segmentedItemsFactory = SendReceiveSegmentedItemsFactory(builder: builder)

        leadingButtonTapRelay
            .bindAndCatch(weak: self) { (self) in
                self.drawerRouter.toggleSideMenu()
            }
            .disposed(by: disposeBag)

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
