// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FirebasePerformance
import Foundation
import ToolKit

final class PerformanceTracingService: PerformanceTracingAPI {

    private typealias CreateTrace = (TraceID) -> Trace?

    private typealias ListenForLogout = (@escaping () -> Void) -> Void

    static let live = PerformanceTracingService(
        createTrace: Trace.createTrace(with:),
        listenForLogout: { onLogout in
            NotificationCenter.when(.logout) { _ in
                onLogout()
            }
        }
    )

    static let mock = PerformanceTracingService(
        createTrace: { _ in nil },
        listenForLogout: { _ in }
    )

    private let traces: Atomic<[TraceID: Trace]>
    private let createTrace: CreateTrace

    private init(
        createTrace: @escaping CreateTrace,
        initialTraces: [TraceID: Trace] = [:],
        listenForLogout: @escaping ListenForLogout
    ) {
        traces = Atomic(initialTraces)
        self.createTrace = createTrace

        listenForLogout { [traces] in
            traces.mutate { currentTraces in
                currentTraces = [:]
            }
        }
    }

    func begin(trace traceId: TraceID) {
        removeTrace(with: traceId)
        if let trace = createTrace(traceId) {
            traces.mutate { traces in
                traces[traceId] = trace
            }
        }
    }

    func end(trace traceId: TraceID) {
        guard let trace = traces.value[traceId] else { return }
        trace.stop()
        removeTrace(with: traceId)
    }

    private func removeTrace(with traceId: TraceID) {
        traces.mutate { traces in
            traces.removeValue(forKey: traceId)
        }
    }
}

private struct Trace {

    private class DebugTrace {

        private enum State {

            struct Started {
                let traceId: TraceID
                let startTime: Date
            }

            struct Ended {
                let traceId: TraceID
                let startTime: Date
                let endTime: Date
                let timeInterval: TimeInterval
            }

            case started(Started)
            case ended(Ended)
        }

        private var state: State

        func stop() {
            guard case .started(let started) = state else { return }

            let traceId = started.traceId
            let startTime = started.startTime
            let endTime = Date()
            let timeInterval = endTime.timeIntervalSince(startTime)
            let endState = State.Ended(
                traceId: traceId,
                startTime: startTime,
                endTime: endTime,
                timeInterval: timeInterval
            )
            state = .ended(endState)

            Self.printTrace(ended: endState)
        }

        convenience init(traceId: TraceID) {
            self.init(
                state: .started(.init(traceId: traceId, startTime: Date()))
            )
        }

        private init(state: State) {
            self.state = state
        }

        private static func printTrace(ended: State.Ended) {
            let traceId = ended.traceId
            let timeInterval = ended.timeInterval
            let seconds = timeInterval.string(with: 2)
            Logger.shared.debug(
                "Trace \(traceId.rawValue), finished in \(seconds) seconds"
            )
        }
    }

    private enum TraceType {
        case debugTrace(DebugTrace)
        case remoteTrace(FirebasePerformance.Trace)

        func stop() {
            switch self {
            case .debugTrace(let debugTrace):
                debugTrace.stop()
            case .remoteTrace(let remoteTrace):
                remoteTrace.stop()
            }
        }

        static func debugTrace(with traceId: TraceID) -> Self {
            .debugTrace(DebugTrace(traceId: traceId))
        }

        static func remoteTrace(with traceId: TraceID) -> Self? {
            guard let remoteTrace = Performance.startTrace(name: traceId.rawValue) else {
                return nil
            }
            return .remoteTrace(remoteTrace)
        }
    }

    private let trace: TraceType

    private init(trace: TraceType) {
        self.trace = trace
    }

    func stop() {
        trace.stop()
    }

    static func createTrace(with traceId: TraceID) -> Self? {
        #if DEBUG || INTERNAL_BUILD
        Self(trace: .debugTrace(with: traceId))
        #else
        guard let remoteTrace = TraceType.remoteTrace(with: traceId) else {
            return nil
        }
        return Self(trace: remoteTrace)
        #endif
    }
}
