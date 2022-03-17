import BlockchainNamespace
import ComposableArchitecture
import CustomDump
import Foundation

public protocol BlockchainNamespaceAppEnvironment {
    var app: AppProtocol { get }
}

public protocol BlockchainNamespaceObservationAction {
    static func observation(_ action: BlockchainNamespaceObservation) -> Self
}

public protocol BlockchainNamespacePostAction {
    static func post(_ ref: Tag.Reference, context: Tag.Reference.Context) -> Self
}

public enum BlockchainNamespaceObservation: Equatable {
    case start, stop
    case event(Tag.Reference, context: Tag.Reference.Context = [:])
}

extension BlockchainNamespaceObservation {

    public static func on(_ event: L, context: L.Context = [:]) -> Self {
        on(event[], context: context.mapKeys(\.[]))
    }

    public static func on(_ event: Tag, context: Tag.Context = [:]) -> Self {
        on(event.ref, context: context)
    }

    public static func on(_ event: Tag.Reference, context: Tag.Reference.Context = [:]) -> Self {
        .event(event, context: context)
    }
}

public struct BlockchainNamespaceEvent: Equatable {

    public let ref: Tag.Reference
    public let context: Tag.Context

    public init(event ref: Tag.Reference, context: Tag.Context) {
        self.ref = ref
        self.context = context
    }
}

extension BlockchainNamespacePostAction {

    public static func post(event id: L, context: L.Context = [:]) -> Self {
        post(event: id[], context: context.mapKeys(\.[]))
    }

    public static func post(event tag: Tag, context: Tag.Context = [:]) -> Self {
        post(event: tag.ref, context: context)
    }

    public static func post(event ref: Tag.Reference, context: Tag.Reference.Context = [:]) -> Self {
        .post(ref, context: context)
    }
}

extension Reducer where Action: BlockchainNamespaceObservationAction, Environment: BlockchainNamespaceAppEnvironment {

    public func on(_ first: L, _ rest: L...) -> Reducer {
        on(Set([first[].ref] + rest.map(\.[].ref)))
    }

    public func on(_ first: Tag, _ rest: Tag...) -> Reducer {
        on(Set([first.ref] + rest.map(\.ref)))
    }

    public func on(_ first: Tag.Reference, _ rest: Tag.Reference...) -> Reducer {
        on(Set([first] + rest))
    }

    public func on<C: Collection>(_ events: C) -> Reducer where C.Element == Tag.Reference {
        Reducer { _, action, environment in
            if let observation = (/Action.observation).extract(from: action) {
                switch observation {
                case .start:
                    let observers = events.map { event in
                        environment.app.on(event)
                            .eraseToEffect()
                            .map { Action.observation(.event($0.ref, context: $0.context)) }
                            .cancellable(id: event)
                    }
                    return .merge(observers)
                case .stop:
                    return .cancel(ids: events.map(AnyHashable.init))
                case .event:
                    break
                }
            }
            return .none
        }
        .combined(with: self)
    }
}

extension Reducer where Action: BlockchainNamespacePostAction, Environment: BlockchainNamespaceAppEnvironment {

    public func autopost() -> Reducer {
        Reducer { _, action, environment in
            if let (event, context) = (/Action.post).extract(from: action) {
                return .fireAndForget {
                    environment.app.post(event: event, context: context)
                }
            }
            return .none
        }
        .combined(with: self)
    }
}

extension Effect where Output: BlockchainNamespacePostAction {

    public func post(event id: L, context: L.Context = [:]) -> Effect {
        post(event: id[], context: context.mapKeys(\.[]))
    }

    public func post(event tag: Tag, context: Tag.Context = [:]) -> Effect {
        post(event: tag.ref(to: context), context: context)
    }

    public func post(event ref: Tag.Reference, context: Tag.Reference.Context = [:]) -> Effect {
        Effect(value: .post(event: ref, context: context))
    }
}

extension Anything: CustomDumpReflectable {

    public var customDumpMirror: Mirror {
        Mirror(reflecting: wrapped)
    }
}

extension Tag: CustomDumpReflectable {

    public var customDumpMirror: Mirror {
        Mirror(reflecting: id)
    }
}

extension Tag.Reference: CustomDumpReflectable {

    public var customDumpMirror: Mirror {
        Mirror(reflecting: string)
    }
}

extension Language {

    public var customDumpMirror: Mirror {
        .init(self, children: ["id": id], displayStyle: .struct)
    }
}
