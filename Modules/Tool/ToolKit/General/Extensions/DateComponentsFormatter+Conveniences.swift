//
//  DateComponentsFormatter+Conveniences.swift
//  ToolKit
//
//  Created by Dimitrios Chatzieleftheriou on 13/04/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension DateComponentsFormatter {
    /// A `DateComponentsFormatter` which outputs a string in the following format "01:10:20"
    public static var countdownFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
}
