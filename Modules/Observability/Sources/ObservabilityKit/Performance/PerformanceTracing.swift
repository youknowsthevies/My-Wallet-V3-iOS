// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

public enum PerformanceTracing {

    public typealias CreateRemoteTrace = (TraceID) -> RemoteTrace

    public typealias ClearTraces = () -> Void

    public typealias ListenForClearTraces = (@escaping ClearTraces) -> Void

    /// Provide the remote tracing service
    /// - Parameters:
    ///   - createRemoteTrace: closure to create a remote trace
    ///   - listenForClearTraces: closure to provide callbacks to clear all traces
    /// - Returns: The performance tracing service
    public static func service(
        createRemoteTrace: @escaping CreateRemoteTrace,
        listenForClearTraces: @escaping ListenForClearTraces
    ) -> PerformanceTracingServiceAPI {
        PerformanceTracingService(
            createTrace: { traceId in
                Trace.createTrace(
                    with: traceId,
                    create: createRemoteTrace
                )
            },
            listenForClearTraces: listenForClearTraces
        )
    }
}
