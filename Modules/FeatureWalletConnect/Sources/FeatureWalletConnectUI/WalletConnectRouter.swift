// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import DIKit
import FeatureWalletConnectDomain
import Foundation
import PlatformUIKit
import SwiftUI
import UIKit
import WalletConnectSwift

class WalletConnectRouter: WalletConnectRouterAPI {

    private var cancellables = [AnyCancellable]()
    private let analyticsEventRecorder: AnalyticsEventRecorderAPI
    private let service: WalletConnectServiceAPI
    @LazyInject private var navigation: NavigationRouterAPI
    @LazyInject private var tabSwapping: TabSwapping

    init(
        analyticsEventRecorder: AnalyticsEventRecorderAPI = resolve(),
        service: WalletConnectServiceAPI = resolve()
    ) {
        self.analyticsEventRecorder = analyticsEventRecorder
        self.service = service

        service.sessionEvents
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] event in
                switch event {
                case .didConnect(let session):
                    self?.didConnect(session: session)
                case .didDisconnect:
                    break
                case .didFailToConnect(let session):
                    self?.didFail(session: session)
                case .didUpdate:
                    break
                case .shouldStart(let session, let action):
                    self?.shouldStart(session: session, action: action)
                }
            })
            .store(in: &cancellables)

        service.userEvents
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] event in
                switch event {
                case .signMessage(let account, let target):
                    self?.tabSwapping.sign(from: account, target: target)
                case .signTransaction(let account, let target):
                    self?.tabSwapping.sign(from: account, target: target)
                case .sendTransaction(let account, let target):
                    self?.tabSwapping.send(from: account, target: target)
                }
            })
            .store(in: &cancellables)
    }

    private func didFail(session: Session) {
        let event = AnalyticsEvents.New.WalletConnect
            .dappConnectionRejected(appName: session.dAppInfo.peerMeta.name)
        analyticsEventRecorder.record(event: event)

        let presenter = navigation.topMostViewControllerProvider.topMostViewController
        let env = WalletConnectEventEnvironment(
            mainQueue: .main,
            service: resolve(),
            router: resolve(),
            onComplete: { _ in
                presenter?.dismiss(animated: true)
            }
        )
        let state = WalletConnectEventState(session: session, state: .fail)
        let store = Store(initialState: state, reducer: walletConnectEventReducer, environment: env)
        let controller = UIHostingController(rootView: WalletConnectEventView(store: store))
        controller.view.backgroundColor = .clear
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overCurrentContext
        presenter?.present(controller, animated: true, completion: nil)
    }

    private func shouldStart(session: Session, action: @escaping (Session.WalletInfo) -> Void) {
        let presenter = navigation.topMostViewControllerProvider.topMostViewController
        let env = WalletConnectEventEnvironment(
            mainQueue: .main,
            service: resolve(),
            router: resolve(),
            onComplete: { [service, analyticsEventRecorder, action] validate in
                presenter?.dismiss(animated: true) {
                    let event: AnalyticsEvents.New.WalletConnect
                    let appName = session.dAppInfo.peerMeta.name
                    if validate {
                        event = .dappConnectionActioned(
                            action: .confirm,
                            appName: appName
                        )
                        service.acceptConnection(action)
                    } else {
                        event = .dappConnectionActioned(
                            action: .cancel,
                            appName: appName
                        )
                        service.denyConnection(action)
                    }
                    analyticsEventRecorder.record(event: event)
                }
            }
        )
        let state = WalletConnectEventState(session: session, state: .idle)
        let store = Store(initialState: state, reducer: walletConnectEventReducer, environment: env)
        let controller = UIHostingController(rootView: WalletConnectEventView(store: store))
        controller.view.backgroundColor = .clear
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overCurrentContext
        presenter?.present(controller, animated: true, completion: nil)
    }

    private func didConnect(session: Session) {
        let event = AnalyticsEvents.New.WalletConnect
            .dappConnectionConfirmed(appName: session.dAppInfo.peerMeta.name)
        analyticsEventRecorder.record(event: event)

        let presenter = navigation.topMostViewControllerProvider.topMostViewController
        let env = WalletConnectEventEnvironment(
            mainQueue: .main,
            service: resolve(),
            router: resolve(),
            onComplete: { _ in
                presenter?.dismiss(animated: true)
            }
        )
        let state = WalletConnectEventState(session: session, state: .success)
        let store = Store(initialState: state, reducer: walletConnectEventReducer, environment: env)
        let controller = UIHostingController(rootView: WalletConnectEventView(store: store))
        controller.view.backgroundColor = .clear
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overCurrentContext
        presenter?.present(controller, animated: true, completion: nil)
    }

    public func showConnectedDApps() {
        let presenter = navigation.topMostViewControllerProvider.topMostViewController
        let env = DAppListEnvironment(
            mainQueue: .main,
            router: resolve(),
            sessionRepository: resolve(),
            onComplete: { _ in
                presenter?.dismiss(animated: true)
            }
        )
        let state = DAppListState()
        let store = Store(initialState: state, reducer: dAppListReducer, environment: env)
        let controller = UIHostingController(rootView: DAppListView(store: store))
        controller.view.backgroundColor = .clear
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overCurrentContext
        presenter?.present(controller, animated: true, completion: nil)
    }

    func showSessionDetails(session: WalletConnectSession) -> AnyPublisher<Void, Never> {
        Deferred {
            Future { [weak self] promise in
                guard let walletConnectSession = session.session else {
                    return
                }

                let presenter = self?.navigation.topMostViewControllerProvider.topMostViewController
                let env = WalletConnectEventEnvironment(
                    mainQueue: .main,
                    service: resolve(),
                    router: resolve(),
                    onComplete: { _ in
                        presenter?.dismiss(animated: true)
                        promise(.success(()))
                    }
                )

                let state = WalletConnectEventState(
                    session: walletConnectSession,
                    state: .details
                )
                let store = Store(initialState: state, reducer: walletConnectEventReducer, environment: env)
                let controller = UIHostingController(rootView: WalletConnectEventView(store: store))
                controller.view.backgroundColor = .clear
                controller.modalTransitionStyle = .crossDissolve
                controller.modalPresentationStyle = .overCurrentContext
                presenter?.present(controller, animated: true, completion: nil)
            }
        }.eraseToAnyPublisher()
    }

    func openWebsite(for client: Session.ClientMeta) {
        UIApplication.shared.open(client.url)
    }
}
