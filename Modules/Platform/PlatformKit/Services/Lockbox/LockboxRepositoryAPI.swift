//
//  LockboxRepository.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol LockboxRepositoryAPI: AnyObject {
    var hasLockbox: Bool { get }
}
