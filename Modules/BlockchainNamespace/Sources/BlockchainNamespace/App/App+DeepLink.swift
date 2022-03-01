// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

extension App {

    public class DeepLink {

        private let rules: [Rule]

        private(set) unowned var app: AppProtocol
        private var bag: Set<AnyCancellable> = []

        init(_ app: AppProtocol) {
            self.app = app
            rules = [
                Rule(
                    pattern: "/app/asset/buy(.*?)",
                    event: "blockchain.app.deep_link.buy",
                    parameters: [
                        .init(
                            name: "code",
                            alias: "blockchain.app.deep_link.buy.crypto.code"
                        )
                    ]
                ),
                Rule(
                    pattern: "/app/asset/send(.*?)",
                    event: "blockchain.app.deep_link.send",
                    parameters: [
                        .init(
                            name: "code",
                            alias: "blockchain.app.deep_link.send.crypto.code"
                        )
                    ]
                ),
                Rule(
                    pattern: "/app/asset(.*?)",
                    event: "blockchain.app.deep_link.asset",
                    parameters: [
                        .init(
                            name: "code",
                            alias: "blockchain.app.deep_link.asset.code"
                        )
                    ]
                ),
                Rule(
                    pattern: "/app/activity(.*?)",
                    event: "blockchain.app.deep_link.activity",
                    parameters: []
                ),
                Rule(
                    pattern: "/app/transaction(.*?)",
                    event: "blockchain.app.deep_link.activity",
                    parameters: [
                        .init(
                            name: "transactionId",
                            alias: "blockchain.app.deep_link.activity.transaction.id"
                        )
                    ]
                ),
                Rule(
                    pattern: "/app/qr/scan(.*?)",
                    event: "blockchain.app.deep_link.qr",
                    parameters: []
                ),
                Rule(
                    pattern: "/app/kyc(.*?)",
                    event: "blockchain.app.deep_link.kyc",
                    parameters: [
                        .init(
                            name: "tier",
                            alias: "blockchain.app.deep_link.kyc.tier"
                        )
                    ]
                )
            ]
        }

        func start() {
            app.on(blockchain.app.process.deep_link)
                .combineLatest(
                    app.publisher(for: blockchain.app.is.ready.for.deep_link, as: Bool.self)
                        .compactMap(\.value)
                        .removeDuplicates()
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
            do {
                guard let match = rules.match(for: url) else {
                    throw ParsingError.nomatch
                }

                let event = try Tag.Reference(id: match.event, in: app.language)
                let context = match.parameters(for: url, with: app)

                app.post(event: event, context: context)
            } catch {
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
                #else
                app.post(error: error)
                #endif
            }
        }
    }
}

extension App.DeepLink {
    enum ParsingError: Error {
        case nomatch
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

extension App.DeepLink {
    public struct Rule: Decodable {
        public init(pattern: String, event: String, parameters: [App.DeepLink.Rule.Parameter]) {
            self.pattern = pattern
            self.event = event
            self.parameters = parameters
        }

        public let pattern: String
        public let event: String
        public let parameters: [Parameter]
    }
}

extension App.DeepLink.Rule {
    public struct Parameter: Decodable {
        public init(name: String, alias: String) {
            self.name = name
            self.alias = alias
        }

        public let name: String
        public let alias: String
    }
}

extension App.DeepLink.Rule {
    public func parameters(for url: URL, with app: AppProtocol) -> [Tag: String] {
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems ?? []

        let params = parameters
            .compactMap { param -> [Tag: String]? in
                guard let item = items[named: param.name],
                      let value = item.value,
                      let tag = try? Tag(id: param.alias, in: app.language)
                else {
                    return nil
                }

                return [tag: value]
            }
            .flatMap { $0 }

        return Dictionary(params, uniquingKeysWith: { $1 })
    }
}

extension Collection where Element == App.DeepLink.Rule {

    public func match(for url: URL) -> App.DeepLink.Rule? {
        compactMap { rule -> (App.DeepLink.Rule, NSRange)? in
            guard let range = url
                .absoluteString
                .range(of: rule.pattern, options: .regularExpression)
            else {
                return nil
            }
            return (rule, NSRange(range, in: url.absoluteString))
        }
        .min(by: { r1, r2 in
            r1.1.length > r2.1.length
        })
        .map(\.0)
    }
}

extension Collection where Element == URLQueryItem {

    public subscript(named name: String) -> URLQueryItem? {
        item(named: name)
    }

    public func item(named name: String) -> URLQueryItem? {
        first(where: { $0.name == name })
    }
}
