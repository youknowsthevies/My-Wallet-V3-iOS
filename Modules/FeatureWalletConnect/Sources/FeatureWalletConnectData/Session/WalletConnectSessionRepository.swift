// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletConnectSwift

protocol SessionRepositoryAPI {
    func contains(session: WalletConnectSession) -> Result<Bool, Never>
    func store(session: WalletConnectSession) -> Result<Void, Never>
    func remove(session: WalletConnectSession) -> Result<Void, Never>
    func removeAll() -> Result<Void, Never>
    func retrieve() -> Result<[WalletConnectSession], Never>
}

struct SessionStorageModel: Codable {
    let sessions: [WalletConnectSession]
}

final class SessionRepository: SessionRepositoryAPI {

    private enum Constants {
        static let userDefaultsKey = "com.blockchain.wallet-connect.sessions"
    }

    private let userDefaults: UserDefaults = .standard

    func store(session: WalletConnectSession) -> Result<Void, Never> {
        retrieve()
            .map { sessions in
                var sessions = sessions
                    .filter { item in
                        !item.isEqual(session)
                    }
                sessions.append(session)
                return sessions
            }
            .flatMap { sessions in
                store(sessions: sessions)
            }
    }

    func remove(session: WalletConnectSession) -> Result<Void, Never> {
        retrieve()
            .map { sessions in
                sessions.filter { item in
                    !item.isEqual(session)
                }
            }
            .flatMap { sessions in
                store(sessions: sessions)
            }
    }

    func removeAll() -> Result<Void, Never> {
        Result<Void, Never>
            .success(())
            .map { [userDefaults] _ in
                userDefaults.removeObject(forKey: Constants.userDefaultsKey)
            }
    }

    func retrieve() -> Result<[WalletConnectSession], Never> {
        loadSessions()
            .map(\.sessions)
    }

    func contains(session: WalletConnectSession) -> Result<Bool, Never> {
        retrieve()
            .map { sessions in
                sessions
                    .contains(where: { $0.isEqual(session) })
            }
    }

    private func loadSessions() -> Result<SessionStorageModel, Never> {
        Result<Void, Never>
            .success(())
            .map { [userDefaults] _ in
                userDefaults.codable(SessionStorageModel.self, forKey: Constants.userDefaultsKey)
                    ?? SessionStorageModel(sessions: [])
            }
    }

    private func store(sessions: [WalletConnectSession]) -> Result<Void, Never> {
        Result<Void, Never>
            .success(())
            .map { [userDefaults] _ in
                let model = SessionStorageModel(sessions: sessions)
                userDefaults.set(codable: model, forKey: Constants.userDefaultsKey)
            }
    }
}

extension SessionRepositoryAPI {

    func contains(session: Session) -> Result<Bool, Never> {
        contains(
            session: WalletConnectSession(session: session)
        )
    }

    func store(session: Session) -> Result<Void, Never> {
        store(
            session: WalletConnectSession(session: session)
        )
    }

    func remove(session: Session) -> Result<Void, Never> {
        remove(
            session: WalletConnectSession(session: session)
        )
    }
}
