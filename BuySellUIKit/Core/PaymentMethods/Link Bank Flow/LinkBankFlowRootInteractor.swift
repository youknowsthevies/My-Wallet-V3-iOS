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
import RxCocoa
import RxSwift

enum LinkBankFlow {
    enum FailureReason: Error {
        case generic
    }
    enum Screen {
        case splash(data: BankLinkageData)
        case yodlee(data: BankLinkageData)
        case failure(FailureReason)
    }
    enum Action: Equatable {
        case load
        case retry
    }
}

protocol LinkBankFlowRootRouting: Routing {
    func route(to screen: LinkBankFlow.Screen)
    func closeFailureScreen()
    func closeFlow()
}

final class LinkBankFlowRootInteractor: Interactor,
                                        LinkBankFlowRootInteractable {

    // MARK: - Properties
    weak var router: LinkBankFlowRootRouting?

    // MARK: - Private Properties
    internal let retryAction = PublishRelay<LinkBankFlow.Action>()
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

        let loadAction = Observable<LinkBankFlow.Action>.just(.load)
        let retryAction = self.retryAction
            .asObservable()
            .share(replay: 1, scope: .whileConnected)

        Observable.merge(loadAction, retryAction)
            .flatMapLatest { [linkedBankService, loadingViewPresenter] _ -> Single<Result<BankLinkageData?, BankLinkageError>> in
                linkedBankService.bankLinkageStartup
                    .handleLoaderForLifecycle(loader: loadingViewPresenter, style: .circle)
                    .catchErrorJustReturn(.failure(.generic))
            }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: handleInitialRouting)
            .disposeOnDeactivate(interactor: self)

        retryAction
            .subscribe(onNext: { [router] _ in
                router?.closeFailureScreen()
            })
            .disposeOnDeactivate(interactor: self)
    }

    func route(to screen: LinkBankFlow.Screen) {
        router?.route(to: screen)
    }

    func closeFlow() {
        router?.closeFlow()
    }

    // MARK: - Private

    private func handleInitialRouting(with result: Result<BankLinkageData?, BankLinkageError>) {
        switch result {
        case .success(let data):
            guard let data = data else {
                router?.route(to: .failure(.generic))
                return
            }
            guard supportedParters.contains(data.partner) else {
                router?.route(to: .failure(.generic))
                return
            }
            router?.route(to: .splash(data: data))
        case .failure:
            router?.route(to: .failure(.generic))
        }
    }
}
