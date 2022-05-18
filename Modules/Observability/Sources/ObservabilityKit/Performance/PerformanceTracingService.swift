// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

final class PerformanceTracingService: PerformanceTracingServiceAPI {

    typealias CreateTrace = (TraceID) -> Trace?

    private let traces: Atomic<[TraceID: Trace]>
    private let createTrace: CreateTrace

    init(
        createTrace: @escaping CreateTrace,
        initialTraces: [TraceID: Trace] = [:],
        listenForClearTraces: @escaping PerformanceTracing.ListenForClearTraces
    ) {
        traces = Atomic(initialTraces)
        self.createTrace = createTrace

        listenForClearTraces { [traces] in
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
