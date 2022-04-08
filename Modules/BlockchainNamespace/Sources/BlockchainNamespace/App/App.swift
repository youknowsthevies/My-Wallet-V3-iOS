// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FirebaseProtocol
import Foundation

public protocol AppProtocol: AnyObject, CustomStringConvertible {

    var language: Language { get }

    var events: Session.Events { get }
    var state: Session.State { get }
    var observers: Session.Observers { get }
    var remoteConfiguration: Session.RemoteConfiguration { get }

    #if canImport(SwiftUI)
    var environmentObject: App.EnvironmentObject { get }
    #endif
}

public class App: AppProtocol {

    public let language: Language

    public let events: Session.Events
    public let state: Session.State
    public let observers: Session.Observers
    public let remoteConfiguration: Session.RemoteConfiguration

    #if canImport(SwiftUI)
    public lazy var environmentObject = App.EnvironmentObject(self)
    #endif

    internal lazy var deepLinks = DeepLink(self)

    public convenience init<Remote: RemoteConfiguration_p>(
        language: Language = Language.root.language,
        remote: Remote
    ) {
        self.init(
            language: language,
            remoteConfiguration: Session.RemoteConfiguration(remote: remote)
        )
    }

    init(
        language: Language = Language.root.language,
        events: Session.Events = .init(),
        state: Session.State = .init(),
        observers: Session.Observers = .init(),
        remoteConfiguration: Session.RemoteConfiguration
    ) {
        defer { start() }
        self.language = language
        self.events = events
        self.state = state
        self.observers = observers
        self.remoteConfiguration = remoteConfiguration
    }

    private func start() {
        state.app = self
        deepLinks.start()
        remoteConfiguration.start(app: self)
        #if DEBUG
        _ = logger
        #endif
    }

    // Observers

    private lazy var logger = events.sink { event in
        if
            let message = event.context[e.message] as? String,
            let file = event.context[e.file] as? String,
            let line = event.context[e.line] as? Int
        {
            print("🏷 ‼️", event.reference, message, "←", file, line)
        } else {
            print("🏷", event.reference, "←", event.source.file, event.source.line)
        }
    }
}

extension AppProtocol {

    public func signIn(userId: String) {
        post(event: blockchain.session.event.will.sign.in)
        state.transaction { state in
            state.set(blockchain.user.id, to: userId)
        }
        post(event: blockchain.session.event.did.sign.in)
    }

    public func signOut() {
        post(event: blockchain.session.event.will.sign.out)
        state.transaction { state in
            state.clear(blockchain.user.id)
        }
        post(event: blockchain.session.event.did.sign.out)
    }
}

extension AppProtocol {

    public func post(
        value: AnyHashable,
        of event: Tag.Event,
        file: String = #fileID,
        line: Int = #line
    ) {
        state.set(event.key, to: value)
        post(event: event, context: [event: value])
    }

    public func post(
        event: Tag.Event,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        events.send(
            Session.Event(
                event: event,
                context: [
                    s.file: file,
                    s.line: line
                ] + context,
                file: file,
                line: line
            )
        )
    }

    public func post<E: Error>(
        _ tag: L_blockchain_ux_type_analytics_error,
        error: E,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        post(tag[], error: error, context: context, file: file, line: line)
    }

    public func post<E: Error>(
        error: E,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        if let error = error as? Tag.Error {
            post(error.event, error: error, context: context, file: error.file, line: error.line)
        } else {
            post(blockchain.ux.type.analytics.error, error: error, context: context, file: file, line: line)
        }
    }

    private func post<E: Error>(
        _ event: Tag.Event,
        error: E,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        events.send(
            Session.Event(
                event: event,
                context: context + [
                    e.message: "\(error.localizedDescription)",
                    e.file: file,
                    e.line: line
                ]
            )
        )
    }

    public func on(
        _ first: Tag.Event,
        _ rest: Tag.Event...
    ) -> AnyPublisher<Session.Event, Never> {
        on([first] + rest)
    }

    public func on<Tags>(
        _ tags: Tags
    ) -> AnyPublisher<Session.Event, Never> where Tags: Sequence, Tags.Element == Tag.Event {
        events.filter(tags.map(\.key)).eraseToAnyPublisher()
    }
}

private let e = (
    message: blockchain.ux.type.analytics.error.message[],
    file: blockchain.ux.type.analytics.error.source.file[],
    line: blockchain.ux.type.analytics.error.source.line[]
)

private let s = (
    file: blockchain.ux.type.analytics.event.source.file[],
    line: blockchain.ux.type.analytics.event.source.line[]
)

extension AppProtocol {

    public func publisher<T>(for event: Tag.Event, as _: T.Type) -> AnyPublisher<FetchResult.Value<T>, Never> {
        publisher(for: event.key)
            .decode(as: T.self)
    }

    public func publisher(for event: Tag.Event) -> AnyPublisher<FetchResult, Never> {
        let ref = event.key
        switch ref.tag {
        case blockchain.session.state.value, blockchain.db.collection.id:
            return state.publisher(for: ref)
        case blockchain.session.configuration.value:
            return remoteConfiguration.publisher(for: ref)
        default:
            return Just(.error(.keyDoesNotExist(ref), ref.metadata()))
                .eraseToAnyPublisher()
        }
    }
}

extension App {
    public var description: String { "App \(language.id)" }
}

extension App {

    public static var preview: AppProtocol = App()

    public convenience init() { self.init(remote: Mock.RemoteConfiguration()) }
}

#if DEBUG
extension App {
    public static var test: AppProtocol { App() }
}
#endif
