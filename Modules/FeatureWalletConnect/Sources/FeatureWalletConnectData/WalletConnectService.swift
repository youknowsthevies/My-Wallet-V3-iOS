// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureWalletConnectDomain
import Foundation
import PlatformKit
import ToolKit
import WalletConnectSwift

final class WalletConnectService {

    // MARK: - Private Properties

    private var server: Server!
    private var cancellables = [AnyCancellable]()
    private var sessionLinks = Atomic<[WCURL: Session]>([:])

    private let didConnectSubject = PassthroughSubject<Session, Never>()
    private let didFailSubject = PassthroughSubject<Session.ClientMeta, Never>()
    private let shouldStartSubject = PassthroughSubject<(Session, (Session.WalletInfo) -> Void), Never>()
    private let didDisconnectSubject = PassthroughSubject<Session, Never>()
    private let didUpdateSubject = PassthroughSubject<Session, Never>()
    private let userEventsSubject = PassthroughSubject<WalletConnectUserEvent, Never>()

    private let sessionRepository: SessionRepositoryAPI
    private let publicKeyProvider: WalletConnectPublicKeyProviderAPI

    // MARK: - Init

    init(
        publicKeyProvider: WalletConnectPublicKeyProviderAPI = resolve(),
        sessionRepository: SessionRepositoryAPI = SessionRepository()
    ) {
        self.sessionRepository = sessionRepository
        self.publicKeyProvider = publicKeyProvider
        server = Server(delegate: self)
        configureServer()
    }

    // MARK: - Private Methods

    private func configureServer() {
        // PrintRequestHandler for debugging.
        server.register(
            handler: PrintRequestHandler()
        )

        // personal_sign, eth_sign, eth_signTypedData
        server.register(
            handler: SignRequestHandler(
                userEvent: { [userEventsSubject] userEvent in
                    userEventsSubject.send(userEvent)
                },
                responseEvent: { [weak server] responseEvent in
                    switch responseEvent {
                    case .invalid(let request):
                        server?.send(.invalid(request))
                    case .signature(let string, let request):
                        server?.send(.signature(string, for: request))
                    }
                },
                getSession: { [sessionLinks] url in
                    sessionLinks.value[url]
                }
            )
        )

        sessionRepository
            .retrieve()
            .publisher
            .sink { [server] sessions in
                sessions
                    .compactMap(\.session)
                    .forEach { session in
                        try? server?.reconnect(to: session)
                    }
            }
            .store(in: &cancellables)
    }
}

extension WalletConnectService: ServerDelegate {

    // MARK: - ServerDelegate

    func server(_ server: Server, didFailToConnect url: WCURL) {
        guard let session = sessionLinks.value[url] else {
            return
        }
        didFailSubject.send(session.dAppInfo.peerMeta)
    }

    func server(_ server: Server, shouldStart session: Session, completion: @escaping (Session.WalletInfo) -> Void) {
        sessionLinks.mutate {
            $0[session.url] = session
        }
        shouldStartSubject.send((session, completion))
    }

    func server(_ server: Server, didConnect session: Session) {
        sessionRepository
            .contains(session: session)
            .publisher
            .flatMap { [sessionRepository] containsSession in
                sessionRepository
                    .store(session: session)
                    .publisher
                    .map { containsSession }
            }
            .sink { [didConnectSubject] containsSession in
                if !containsSession {
                    didConnectSubject.send(session)
                }
            }
            .store(in: &cancellables)
    }

    func server(_ server: Server, didDisconnect session: Session) {
        sessionRepository
            .remove(session: session)
            .publisher
            .sink { [didDisconnectSubject] _ in
                didDisconnectSubject.send(session)
            }
            .store(in: &cancellables)
    }

    func server(_ server: Server, didUpdate session: Session) {
        sessionRepository
            .store(session: session)
            .publisher
            .sink { [didUpdateSubject] _ in
                didUpdateSubject.send(session)
            }
            .store(in: &cancellables)
    }
}

extension WalletConnectService: WalletConnectServiceAPI {

    // MARK: - WalletConnectServiceAPI

    var userEvents: AnyPublisher<WalletConnectUserEvent, Never> {
        userEventsSubject.eraseToAnyPublisher()
    }

    var sessionEvents: AnyPublisher<WalletConnectSessionEvent, Never> {
        let didConnect = didConnectSubject
            .map { WalletConnectSessionEvent.didConnect($0) }
            .eraseToAnyPublisher()
        let didFail = didFailSubject
            .map { WalletConnectSessionEvent.didFailToConnect($0) }
            .eraseToAnyPublisher()
        let shouldStart = shouldStartSubject
            .map { WalletConnectSessionEvent.shouldStart($0.0, $0.1) }
            .eraseToAnyPublisher()
        let didDisconnect = didDisconnectSubject
            .map { WalletConnectSessionEvent.didDisconnect($0) }
            .eraseToAnyPublisher()
        let didUpdate = didUpdateSubject
            .map { WalletConnectSessionEvent.didUpdate($0) }
            .eraseToAnyPublisher()

        return Publishers
            .MergeMany(didConnect, didFail, shouldStart, didDisconnect, didUpdate)
            .eraseToAnyPublisher()
    }

    func acceptConnection(_ completion: @escaping (Session.WalletInfo) -> Void) {
        publicKeyProvider
            .publicKey
            .map { publicKey in
                Session.WalletInfo(
                    approved: true,
                    accounts: [publicKey],
                    chainId: 1,
                    peerId: UUID().uuidString,
                    peerMeta: .blockchain
                )
            }
            .sink { [completion] walletInfo in
                completion(walletInfo)
            }
            .store(in: &cancellables)
    }

    func denyConnection(_ completion: @escaping (Session.WalletInfo) -> Void) {
        let walletInfo = Session.WalletInfo(
            approved: false,
            accounts: [],
            chainId: 1,
            peerId: UUID().uuidString,
            peerMeta: .blockchain
        )
        completion(walletInfo)
    }

    func connect(_ url: String) {
        guard let wcUrl = WCURL(url) else {
            return
        }
        try? server.connect(to: wcUrl)
    }
}

extension Response {
    static func signature(_ signature: String, for request: Request) -> Response {
        guard let response = try? Response(url: request.url, value: signature, id: request.id!) else {
            fatalError("Response Signature Failed")
        }
        return response
    }
}
