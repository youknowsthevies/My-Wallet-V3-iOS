//
//  ProbabilisticRunner.swift
//  ToolKit
//
//  Created by Jack Pooley on 23/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

/// Run a specified block probabilistically with an assigned percentage probability
public final class ProbabilisticRunner {
    
    /// The percentage used for the run
    public struct Percentage {
        
        enum PercentageError: Error {
            case invalidInput
        }
        
        // swiftlint:disable force_try
        
        public static let onePercent = try! Percentage(percentage: 1)
        public static let fivePercent = try! Percentage(percentage:  5)
        public static let tenPercent = try! Percentage(percentage: 10)
        public static let twentyPercent = try! Percentage(percentage: 20)
        public static let fiftyPercent = try! Percentage(percentage: 50)
        
        fileprivate static let min = 0
        fileprivate static let max = 100
        
        fileprivate let percentage: Int
        
        fileprivate init(percentage: Int) throws {
            guard percentage >= Self.min, percentage <= Self.max else {
                throw PercentageError.invalidInput
            }
            self.percentage = percentage
        }
    }
    
    /// Run the specified `block` probabilistically for a specified percentage of runs
    /// - Parameters:
    ///   - percentage: The percentage probability to use
    ///   - block: The block to run
    public static func run(for percentage: Percentage, block: () -> Void) {
        if shouldRun(for: percentage) {
            block()
        }
    }
    
    private static func shouldRun(for percentage: Percentage) -> Bool {
        let number = Int.random(in: Percentage.min...Percentage.max)
        return number <= percentage.percentage
    }
}
