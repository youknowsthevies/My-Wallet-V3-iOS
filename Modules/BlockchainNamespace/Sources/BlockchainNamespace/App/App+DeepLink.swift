// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

extension App {

    class DeepLink {

        private(set) unowned var app: AppProtocol
        private var bag: Set<AnyCancellable> = []

        init(_ app: AppProtocol) {
            self.app = app
        }

        func start() {
            app.on(blockchain.app.process.deep_link)
                .combineLatest(
                    app.publisher(for: blockchain.app.is.ready.for.deep_link, as: Bool.self)
                        .compactMap(\.value)
                )
                .filter(\.1)
                .map(\.0)
                .sink { [weak self] event in self?.process(event: event) }
                .store(in: &bag)
        }

        func process(event: Session.Event) {
            do {
                try process(
                    url: event.context.decode(blockchain.app.process.deep_link.url, as: URL.self)
                )
            } catch {
                app.post(error: error)
            }
        }

        func process(url: URL) {
            #if DEBUG
            do {
                let dsl = try DSL(url, app: app)
                app.state.transaction { state in
                    for (tag, value) in dsl.context {
                        state.set(tag, to: value)
                    }
                }
                if let event = dsl.event {
                    app.post(event: event, context: dsl.context)
                }
            } catch {
                app.post(error: error)
            }
            #endif
        }
    }
}

extension App.DeepLink {

    struct DSL: Equatable, Codable {
        var event: Tag.Reference?
        var context: [Tag: String] = [:]
    }
}

extension App.DeepLink.DSL {

    struct Error: Swift.Error {
        let message: String
    }

    static func isDSL(_ url: URL) -> Bool {
        url.path == "/app"
    }

    init(_ url: URL, app: AppProtocol) throws {
        guard App.DeepLink.DSL.isDSL(url) else {
            throw Error(message: "Not a \(Self.self): \(url)")
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw Error(message: "Failed to initialise a \(Self.self) from url \(url)")
        }
        event = try components.fragment.map { try Tag.Reference(id: $0, in: app.language) }
        var context: [Tag: String] = [:]
        for item in components.queryItems ?? [] {
            try context[Tag(id: item.name, in: app.language)] = item.value
        }
        self.context = context
    }
}
