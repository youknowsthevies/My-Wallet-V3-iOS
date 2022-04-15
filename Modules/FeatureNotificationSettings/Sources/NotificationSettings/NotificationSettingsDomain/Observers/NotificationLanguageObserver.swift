//
//  File.swift
//
//
//  Created by Augustin Udrea on 15/04/2022.
//

import BlockchainNamespace
import Combine
import DIKit
import Foundation

public final class NotificationLanguageObserver: Session.Observer {
    let app: AppProtocol
    let contactLanguagePreferenceService: ContactLanguagePreferenceServiceAPI
    let locale: Locale
    private var cancellables: Set<AnyCancellable> = []

    public init(
        app: AppProtocol,
        contactLanguagePreferenceService: ContactLanguagePreferenceServiceAPI = resolve(),
        locale: Locale = .current
    ) {
        self.app = app
        self.contactLanguagePreferenceService = contactLanguagePreferenceService
        self.locale = locale
    }

    var observers: [BlockchainEventSubscription] {
        [login]
    }

    public func start() {
        for observer in observers {
            observer.start()
        }
    }

    public func stop() {
        for observer in observers {
            observer.stop()
        }
    }

    lazy var login = app.on(blockchain.session.event.did.sign.in) { [weak self] _ in
        guard let self = self,
              let languageCode = self.locale.languageCode else { return }

//        self.contactLanguagePreferenceService
//            .updateLanguage(language: languageCode)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure(let error):
//                    print(error)
//                case .finished:
//                    return
//                }
//            }, receiveValue: { _ in })
//            .store(in: &self.cancellables)
    }
}
