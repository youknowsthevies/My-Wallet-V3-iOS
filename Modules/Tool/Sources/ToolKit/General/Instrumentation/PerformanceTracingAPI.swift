// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// The ID of the Trace
public enum TraceID: String {

    /// This trace should start when the PIN is enterered to the dashboard appearing
    case pinToDashboard = "ios_trace_pin_to_dashboard"
}

/// This API provides a mechanism to trace metrics from the beginning to the end of a trace
public protocol PerformanceTracingAPI {

    /// Start the trace
    /// - Parameter traceId: the unique ID to record this trace
    func begin(trace traceId: TraceID)

    /// End the trace
    /// - Parameter traceId: the unique ID to record this trace
    func end(trace traceId: TraceID)
}
