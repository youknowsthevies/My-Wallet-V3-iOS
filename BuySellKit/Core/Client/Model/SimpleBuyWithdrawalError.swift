//
//  SimpleBuyWithdrawalError.swift
//  PlatformKit
//
//  Created by AlexM on 2/12/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum SimpleBuyWithdrawalError: Int, Error {
    case withdrawalPending = 403
    case insufficientBalance = 409
}
