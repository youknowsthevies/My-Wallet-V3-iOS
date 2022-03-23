#if canImport(SwiftUI)

import SwiftUI

public typealias BlockchainApp = EnvironmentObject<App.EnvironmentObject>

extension App {

    public class EnvironmentObject: NSObject, ObservableObject, AppProtocol {

        let app: AppProtocol

        public var language: Language { app.language }
        public var events: Session.Events { app.events }
        public var state: Session.State { app.state }
        public var observers: Session.Observers { app.observers }
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

    public func context(_ context: Tag.Context) -> some View {
        environment(\.context, context)
    }
}

extension EnvironmentValues {

    public var context: Tag.Context {
        get { self[BlockchainAppContext.self] }
        set { self[BlockchainAppContext.self] += newValue }
    }
}

public struct BlockchainAppContext: EnvironmentKey {
    public static let defaultValue: Tag.Context = [:]
}

extension View {

    public func on(
        _ event: Tag.Event,
        _ rest: Tag.Event...,
        file: String = #fileID,
        line: Int = #line,
        perform action: @escaping (Session.Event) async throws -> Void
    ) -> some View {
        on([event] + rest, file: file, line: line, perform: action)
    }

    public func on<C: Collection>(
        _ events: C,
        file: String = #fileID,
        line: Int = #line,
        perform action: @escaping (Session.Event) async throws -> Void
    ) -> some View where C.Element == Tag.Event {
        modifier(
            AsyncOnReceiveSessionEvents(
                events: events.map { event in event.key }.set,
                action: action,
                file: file,
                line: line
            )
        )
    }
}

public struct AsyncOnReceiveSessionEvents: ViewModifier {

    @BlockchainApp var app
    @Environment(\.context) var context

    public let events: Set<Tag.Reference>
    let action: (Session.Event) async throws -> Void

    let file: String
    let line: Int

    private var __events: [Tag.Reference] {
        events.map { event in
            if event.hasError {
                return Tag.Reference(event.tag, to: event.context, in: app)
            } else {
                return event
            }
        }
    }

    @State private var removed: Bool = false

    public func body(content: Content) -> some View {
        if removed {
            content.onAppear { removed = false }
        } else {
            content
                .onDisappear { removed = true }
                .padding(0)
                .onReceive(app.on(__events)) { [weak app] event in
                    Task(priority: .high) { @MainActor [weak app] in
                        do {
                            try await action(event)
                        } catch {
                            app?.post(error: error, file: file, line: line)
                        }
                    }
                }
        }
    }
}

#endif
