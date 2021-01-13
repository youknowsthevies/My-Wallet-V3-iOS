//
//  YodleeScreenInteractor.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 11/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import Localization
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift

enum YodleeScreen {
    enum Action: Equatable {
        case pending(content: YodleePendingContent)
        case success(content: YodleePendingContent)
        case failure(content: YodleePendingContent)
        case load(request: URLRequest)
        case none

        var request: URLRequest? {
            switch self {
            case .load(let request):
                return request
            default:
                return nil
            }
        }

        var content: YodleePendingContent? {
            switch self {
            case .pending(let content),
                 .failure(let content),
                 .success(let content):
                return content
            default:
                return nil
            }
        }
    }

    enum Effect: Equatable {
        case link(url: URL)
        case closeFlow
        case none
    }
}

protocol YodleeScreenRouting: ViewableRouting {
    func route(to path: YodleeRoute.Path)
}

protocol YodleeScreenPresentable: Presentable {
    func connect(action: Driver<YodleeScreen.Action>) -> Driver<YodleeScreen.Effect>
}

protocol YodleeScreenListener: class {
    func closeFlow()
}

final class YodleeScreenInteractor: PresentableInteractor<YodleeScreenPresentable>, YodleeScreenInteractable {

    weak var router: YodleeScreenRouting?
    weak var listener: YodleeScreenListener?

    private let bankLinkageData: BankLinkageData
    private let checkoutData: CheckoutData
    private let stateService: StateServiceAPI
    private let yodleeRequestProvider: YodleeRequestProvider
    private let yodleeMessageService: YodleeMessageService
    private let yodleeActivationService: YodleeActivateService
    private let contentReducer: YodleeScreenContentReducer

    init(presenter: YodleeScreenPresentable,
         bankLinkageData: BankLinkageData,
         checkoutData: CheckoutData,
         stateService: StateServiceAPI,
         yodleeRequestProvider: YodleeRequestProvider,
         yodleeMessageService: YodleeMessageService,
         yodleeActivationService: YodleeActivateService,
         contentReducer: YodleeScreenContentReducer) {
        self.bankLinkageData = bankLinkageData
        self.checkoutData = checkoutData
        self.stateService = stateService
        self.yodleeRequestProvider = yodleeRequestProvider
        self.yodleeMessageService = yodleeMessageService
        self.yodleeActivationService = yodleeActivationService
        self.contentReducer = contentReducer
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        // register the webkit message handler for events
        yodleeMessageService.startMonitorEvents()

        // Setup actions
        let pendingContent = Driver.just(
            YodleeScreen.Action.pending(content: contentReducer.webviewPendingContent())
        )

        let loadAction = Driver.deferred { [weak self] () -> Driver<URLRequest?> in
            guard let self = self else { return .empty() }
            return .just(self.yodleeRequestProvider.provideRequest(using: self.bankLinkageData))
        }
        .compactMap { $0 }
        .map(YodleeScreen.Action.load)

        // Success message from Yodlee
        let successMessage = yodleeMessageService.effect
            .filter(\.isSuccess)
            .compactMap(\.providerId)

        // Success message from Yodlee
        let errorMessageAction = yodleeMessageService.effect
            .filter(\.isFailure)
            .map { [contentReducer] message in
                YodleeScreen.Action.failure(content: contentReducer.webviewFailureContent())
            }
            .asDriverCatchError()

        let activationResult = successMessage
            .flatMap { [weak self] (providerId) -> Single<YodleeActivateService.State> in
                guard let self = self else { return .just(.timeout) }
                return self.yodleeActivationService
                        .startPolling(for: self.bankLinkageData.id, providerAccountId: providerId)
            }
            .share(replay: 1, scope: .whileConnected)

        let activationContentAction = activationResult
            .filter(\.isActive)
            .map { [weak self] state -> YodleeScreen.Action in
                guard let self = self else { return .none }
                return state.toScreenAction(reducer: self.contentReducer)
            }
            .asDriverCatchError()

        // Handle effects for opening an external url and closure of webview
        yodleeMessageService.effect
            .filter { !$0.isSuccess }
            .map(transformEffect(from:))
            .asDriverCatchError()
            .drive(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)

        let successPendingAction = successMessage
            .map { [weak self] _ -> YodleeScreen.Action in
                guard let self = self else { return .none }
                return .pending(
                    content: self.contentReducer.linkingBankPendingContent()
                )
            }
            .asDriverCatchError()

        contentReducer.continueButtonViewModel.tap
            .asObservable()
            .withLatestFrom(activationResult)
            .filter(\.isActive)
            .compactMap(\.data)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { data in
                let updateData = self.checkoutData.checkoutData(byAppending: data)
                self.listener?.closeFlow()
                self.stateService.nextFromBuyCrypto(with: updateData)
            })
            .disposeOnDeactivate(interactor: self)

        let retryContentFromTap = contentReducer.tryAgainButtonViewModel.tap
            .map { [contentReducer] _ in
                YodleeScreen.Action.pending(content: contentReducer.webviewPendingContent())
            }
            .asDriver(onErrorJustReturn: .none)

        let retryLoadAction = retryContentFromTap
            .compactMap({ [weak self] _ -> URLRequest? in
                guard let self = self else { return nil }
                return self.yodleeRequestProvider.provideRequest(using: self.bankLinkageData)
            })
            .map(YodleeScreen.Action.load)

        contentReducer.cancelButtonViewModel.tap
            .map { _ in YodleeScreen.Effect.closeFlow }
            .emit(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)

        // Presenter Connection
        let pendingActions = Driver.merge(
            pendingContent, retryContentFromTap, successPendingAction, errorMessageAction, activationContentAction
        )
        presenter.connect(action: Driver.merge(loadAction, retryLoadAction, pendingActions))
            .drive(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)
    }

    // MARK: - Private

    private func handle(effect: YodleeScreen.Effect) {
        switch effect {
        case .link(let url):
            router?.route(to: .link(url: url))
        case .closeFlow:
            listener?.closeFlow()
        case .none:
            break
        }
    }

    private func transformEffect(from messageEffect: YodleeMessageService.Effect) -> YodleeScreen.Effect {
        switch messageEffect {
        case .openExternal(let url):
            return .link(url: url)
        case .success:
            return .none // will be handled as an action (successMessage)
        case .closed:
            listener?.closeFlow()
        case .error:
            return .none // will be handled as an action (errorMessageAction)
        case .none:
            return .none
        }
        return .none
    }
}
