//
//  LinkBankFlowRootInteractor.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 10/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import PlatformUIKit
import RIBs
import RxSwift

enum LinkBankFlow {
    enum Screen {
        case splash(data: BankLinkageData)
    }
}

protocol LinkBankFlowRootRouting: Routing {
    func route(to screen: LinkBankFlow.Screen)
    func closeFlow()
}

final class LinkBankFlowRootInteractor: Interactor, LinkBankFlowRootInteractable {

    // MARK: - Properties
    weak var router: LinkBankFlowRootRouting?

    // MARK: - Private Properties
    private let supportedParters: Set<BankLinkageData.Partner> = [.yodlee]

    // MARK: - Injected
    private let linkedBankService: LinkedBanksServiceAPI
    private let loadingViewPresenter: LoadingViewPresenting

    init(linkedBankService: LinkedBanksServiceAPI = resolve(),
         loadingViewPresenter: LoadingViewPresenting = resolve()) {
        self.linkedBankService = linkedBankService
        self.loadingViewPresenter = loadingViewPresenter
        super.init()
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        linkedBankService.bankLinkageStartup
            .handleLoaderForLifecycle(loader: loadingViewPresenter, style: .circle)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: handleInitialRouting,
                       onError: handleInitialRoutingError)
            .disposeOnDeactivate(interactor: self)
    }

    // MARK: - Private

    private func handleInitialRouting(with data: BankLinkageData?) {
        // **Error screen figma link: https://www.figma.com/file/CMA2yX0BRBPfwa2d3W3YzC/iOS-Yodlee-US?node-id=527%3A2639
        guard let data = data else {
            // TODO: ACH - Route to **error screen**
            return
        }
        guard supportedParters.contains(data.partner) else {
            // TODO: ACH - Route to **error screen**
            return
        }
        router?.route(to: .splash(data: data))
    }

    private func handleInitialRoutingError(error: Error) {
        // TODO: ACH - Route to **error screen**
    }
}
