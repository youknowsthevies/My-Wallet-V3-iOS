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
            print("🏷 ‼️", event, message, "←", file, line)
        } else {
            print("🏷", event)
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
        of id: L,
        file: String = #fileID,
        line: Int = #line
    ) {
        state.set(id, to: value)
        post(event: id, context: [id: value])
    }

    public func post(
        value: AnyHashable,
        of tag: Tag,
        file: String = #fileID,
        line: Int = #line
    ) {
        state.set(tag, to: value)
        post(event: tag, context: [tag: value])
    }

    public func post(
        value: AnyHashable,
        of ref: Tag.Reference,
        file: String = #fileID,
        line: Int = #line
    ) {
        state.set(ref, to: value)
        post(event: ref, context: [ref.tag: value])
    }

    public func post(
        event id: L,
        context: L.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        post(event: language[id], context: context.mapKeys(\.[]), file: file, line: line)
    }

    public func post(
        event tag: Tag,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        post(event: tag.ref(in: self), context: context, file: file, line: line)
    }

    public func post(
        event ref: Tag.Reference,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        events.send(
            Session.Event(
                ref: ref,
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
        post(tag[].ref, error: error, context: context, file: file, line: line)
    }

    public func post<E: Error>(
        error: E,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        if let error = error as? Tag.Error {
            post(error.tag.ref(to: error.context), error: error, context: context, file: error.file, line: error.line)
        } else {
            post(blockchain.ux.type.analytics.error[].ref, error: error, context: context, file: file, line: line)
        }
    }

    private func post<E: Error>(
        _ ref: Tag.Reference,
        error: E,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        events.send(
            Session.Event(
                ref: ref,
                context: context + [
                    e.message: "\(error.localizedDescription)",
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
    file: blockchain.ux.type.analytics.error.source.file[],
    line: blockchain.ux.type.analytics.error.source.line[]
)

private let s = (
    file: blockchain.ux.type.analytics.event.source.file[],
    line: blockchain.ux.type.analytics.event.source.line[]
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
