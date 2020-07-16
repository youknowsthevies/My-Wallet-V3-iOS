//
//  ConsoleLogDestination.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import SwiftyBeaver

/// A destination wherein log statements are outputted to standard output (i.e. XCode's console)
public class ConsoleLogDestination: LogDestination {
    public func log(statement: String, level: LogLevel) {
        print(statement)
    }
}

public class SwiftyBeaverDestination: LogDestination {
    
    private let log = SwiftyBeaver.self
    
    public func log(statement: String, level: LogLevel) {
        switch level {
        case .debug:
            log.verbose(statement)
        case .error:
            log.error(statement)
        case .info:
            log.info(statement)
        case .warning:
            log.warning(statement)
        }
    }
}
