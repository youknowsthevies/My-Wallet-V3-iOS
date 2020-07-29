//
//  Executor.swift
//  PlatformUIKit
//
//  Created by Daniel on 16/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//  Implementation Reference: https://github.com/uber/RIBs (RIBs Architecture by Uber)
// 
import Dispatch
import Foundation
import RxSwift

public class Executor {

    /// Execute the given logic after the given delay assuming the given maximum frame duration.
    ///
    /// This allows excluding the time elapsed due to breakpoint pauses.
    ///
    /// - note: The logic closure is not guaranteed to be performed exactly after the given delay. It may be performed
    ///   later if the actual frame duration exceeds the given maximum frame duration.
    ///
    /// - parameter delay: The delay to perform the logic, excluding any potential elapsed time due to breakpoint
    ///   pauses.
    /// - parameter maxFrameDuration: The maximum duration a single frame should take. Defaults to 33ms.
    /// - parameter logic: The closure logic to perform.
    public static func execute(withDelay delay: TimeInterval, maxFrameDuration: Int = 33, logic: @escaping () -> ()) {
        let period = DispatchTimeInterval.milliseconds(maxFrameDuration / 3)
        var lastRunLoopTime = Date().timeIntervalSinceReferenceDate
        var properFrameTime = 0.0
        var didExecute = false
        _ = Observable<Int>
            .timer(DispatchTimeInterval.milliseconds(0), period: period, scheduler: MainScheduler.instance)
            .takeWhile { _ in
                !didExecute
            }
            .subscribe(onNext: { _ in
                let currentTime = Date().timeIntervalSinceReferenceDate
                let trueElapsedTime = currentTime - lastRunLoopTime
                lastRunLoopTime = currentTime

                // If we did drop frame, we under-count the frame duration, which is fine. It
                // just means the logic is performed slightly later.
                let boundedElapsedTime = min(trueElapsedTime, Double(maxFrameDuration) / 1000)
                properFrameTime += boundedElapsedTime
                if properFrameTime > delay {
                    didExecute = true

                    logic()
                }
            })
    }
}
