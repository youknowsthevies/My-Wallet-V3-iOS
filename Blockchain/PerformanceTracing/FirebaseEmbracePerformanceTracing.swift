// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Embrace
import FirebasePerformance
import Foundation
import ObservabilityKit
import ToolKit

extension PerformanceTracing {

    public static let live: PerformanceTracingServiceAPI =
        PerformanceTracing.service(
            createRemoteTrace: { traceId in
                var traces: [RemoteTrace] = []
                if let firebaseTrace = Performance.startTrace(name: traceId.rawValue) {
                    traces.append(firebaseTrace)
                }
                let embraceTrace = EmbraceTrace.start(with: traceId)
                traces.append(embraceTrace)
                return CompoundRemoteTrace(remoteTraces: traces)
            },
            listenForClearTraces: { clearTraces in
                NotificationCenter.when(.logout) { _ in
                    clearTraces()
                }
            }
        )

    public static let mock: PerformanceTracingServiceAPI =
        PerformanceTracing.service(
            createRemoteTrace: { _ in
                CompoundRemoteTrace(remoteTraces: [])
            },
            listenForClearTraces: { _ in }
        )
}

private struct CompoundRemoteTrace: RemoteTrace {

    private let remoteTraces: [RemoteTrace]

    init(remoteTraces: [RemoteTrace]) {
        self.remoteTraces = remoteTraces
    }

    func stop() {
        for trace in remoteTraces {
            trace.stop()
        }
    }
}

extension FirebasePerformance.Trace: RemoteTrace {}

private struct EmbraceTrace: RemoteTrace {

    private let traceId: TraceID

    private init(traceId: TraceID) {
        self.traceId = traceId

        Embrace.sharedInstance().startMoment(withName: traceId.rawValue)
    }

    func stop() {
        Embrace.sharedInstance().endMoment(withName: traceId.rawValue)
    }

    static func start(with traceId: TraceID) -> Self {
        EmbraceTrace(traceId: traceId)
    }
}
