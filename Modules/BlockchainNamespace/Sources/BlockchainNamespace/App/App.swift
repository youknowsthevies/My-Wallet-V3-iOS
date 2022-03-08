// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FirebaseProtocol
import Foundation

public protocol AppProtocol: AnyObject, CustomStringConvertible {

    var language: Language { get }

    var events: Session.Events { get }
    var state: Session.State { get }
    var remoteConfiguration: Session.RemoteConfiguration { get }

    #if canImport(SwiftUI)
    var environmentObject: App.EnvironmentObject { get }
    #endif
}

public class App: AppProtocol {

    public let language: Language

    public let events: Session.Events
    public let state: Session.State
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
            events: .init(),
            state: .init(),
            remoteConfiguration: Session.RemoteConfiguration(remote: remote)
        )
    }

    init(
        language: Language = Language.root.language,
        events: Session.Events = .init(),
        state: Session.State = .init(),
        remoteConfiguration: Session.RemoteConfiguration
    ) {
        defer { start() }
        self.language = language
        self.events = events
        self.state = state
        self.remoteConfiguration = remoteConfiguration
    }

    private func start() {
        state.app = self
        deepLinks.start()
        for o in observers {
            o.store(in: &bag)
        }
    }

    // Observers

    var bag: Set<AnyCancellable> = []
    var observers: [AnyCancellable] {
        #if DEBUG
        let debug: [AnyCancellable] = [logger]
        #else
        let debug: [AnyCancellable] = []
        #endif
        return debug
    }

    lazy var logger = events.sink { event in
        if let message = event.context[e.message] as? String {
            print("🏷 ‼️", event.tag.id, message)
        } else {
            print("🏷", event.tag.id)
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

    public func post(event id: L, context: Tag.Context = [:]) {
        post(event: language[id], context: context)
    }

    public func post(event tag: Tag, context: Tag.Context = [:]) {
        post(event: tag.ref(in: self), context: context)
    }

    public func post(event ref: Tag.Reference, context: Tag.Context = [:]) {
        events.send(Session.Event(ref: ref, context: context))
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
            post(error.tag, error: error, context: context, file: file, line: line)
        } else {
            post(blockchain.ux.type.analytics.error[], error: error, context: context, file: file, line: line)
        }
    }

    private func post<E: Error>(
        _ tag: Tag,
        error: E,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        events.send(
            Session.Event(
                ref: tag.ref(in: self),
                context: context + [
                    e.message: "\(error)",
                    e.file: file,
                    e.line: line
                ]
            )
        )
    }

    public func on(
        _ first: L,
        _ rest: L...
    ) -> AnyPublisher<Session.Event, Never> {
        on([first] + rest)
    }

    public func on<Tags>(
        _ tags: Tags
    ) -> AnyPublisher<Session.Event, Never> where Tags: Sequence, Tags.Element == L {
        on(tags.map(\.[]))
    }

    public func on(
        _ first: Tag,
        _ rest: Tag...
    ) -> AnyPublisher<Session.Event, Never> {
        on([first] + rest)
    }

    public func on<Tags>(
        _ tags: Tags
    ) -> AnyPublisher<Session.Event, Never> where Tags: Sequence, Tags.Element == Tag {
        on(tags.map(\.ref))
    }

    public func on(
        _ first: Tag.Reference,
        _ rest: Tag.Reference...
    ) -> AnyPublisher<Session.Event, Never> {
        on([first] + rest)
    }

    public func on<Tags>(
        _ tags: Tags
    ) -> AnyPublisher<Session.Event, Never> where Tags: Sequence, Tags.Element == Tag.Reference {
        events.filter(tags).eraseToAnyPublisher()
    }
}

private let e = (
    message: blockchain.ux.type.analytics.error.message[],
    file: blockchain.ux.type.analytics.error.file[],
    line: blockchain.ux.type.analytics.error.line[]
)

extension AppProtocol {

    public func publisher<T>(for id: L, as _: T.Type) -> AnyPublisher<FetchResult.Value<T>, Never> {
        publisher(for: id)
            .decode(as: T.self)
    }

    public func publisher<T>(for tag: Tag, as _: T.Type) -> AnyPublisher<FetchResult.Value<T>, Never> {
        publisher(for: tag)
            .decode(as: T.self)
    }

    public func publisher<T>(for ref: Tag.Reference, as _: T.Type) -> AnyPublisher<FetchResult.Value<T>, Never> {
        publisher(for: ref)
            .decode(as: T.self)
    }

    public func publisher(for id: L) -> AnyPublisher<FetchResult, Never> {
        publisher(for: language[id])
    }

    public func publisher(for tag: Tag) -> AnyPublisher<FetchResult, Never> {
        publisher(for: tag.ref(in: self))
    }

    public func publisher(for ref: Tag.Reference) -> AnyPublisher<FetchResult, Never> {
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
