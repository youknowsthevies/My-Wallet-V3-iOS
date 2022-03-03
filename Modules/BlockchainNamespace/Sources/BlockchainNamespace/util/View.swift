#if canImport(SwiftUI)

import SwiftUI

public typealias BlockchainApp = EnvironmentObject<App.EnvironmentObject>

extension App {

    public class EnvironmentObject: NSObject, ObservableObject, AppProtocol {

        let app: AppProtocol

        public var language: Language { app.language }
        public var events: Session.Events { app.events }
        public var state: Session.State { app.state }
        public var remoteConfiguration: Session.RemoteConfiguration { app.remoteConfiguration }
        public var environmentObject: App.EnvironmentObject { self }

        public init(_ app: AppProtocol) {
            self.app = app
            super.init()
        }
    }
}

extension View {

    public func app(_ app: AppProtocol) -> some View {
        environmentObject(app.environmentObject)
    }

    public func context(_ context: L.Context) -> some View {
        environment(\.context, context.mapKeys(\.[]))
    }

    public func context(_ context: Tag.Context) -> some View {
        environment(\.context, context)
    }
}

extension EnvironmentValues {
    public var context: Tag.Reference.Context {
        get { self[BlockchainAppContext.self] }
        set { self[BlockchainAppContext.self] += newValue }
    }
}

public struct BlockchainAppContext: EnvironmentKey {
    public static let defaultValue: Tag.Context = [:]
}

extension View {

    public func on(
        _ event: L,
        perform action: @escaping (Session.Event) throws -> Void
    ) -> some View {
        on([event].map(\.[].ref), perform: action)
    }

    public func on(
        _ event: Tag,
        perform action: @escaping (Session.Event) throws -> Void
    ) -> some View {
        on([event].map(\.ref), perform: action)
    }

    public func on(
        _ event: Tag.Reference,
        perform action: @escaping (Session.Event) throws -> Void
    ) -> some View {
        on([event], perform: action)
    }

    public func on<C: Collection>(
        _ events: C,
        perform action: @escaping (Session.Event) throws -> Void
    ) -> some View where C.Element == Tag.Reference {
        modifier(OnReceiveSessionEvents(events: events.set, action: action))
    }
}

public struct OnReceiveSessionEvents: ViewModifier {

    @BlockchainApp var app
    @Environment(\.context) var context

    public let events: Set<Tag.Reference>
    let action: (Session.Event) throws -> Void

    private var __events: [Tag.Reference] {
        events.map { event in
            if event.hasError {
                return event.ref(to: context, in: app)
            } else {
                return event
            }
        }
    }

    public func body(content: Content) -> some View {
        content.padding(0).onReceive(app.on(__events)) { [weak app] event in
            do {
                try action(event)
            } catch {
                app?.post(error: error)
            }
        }
    }
}

#endif
