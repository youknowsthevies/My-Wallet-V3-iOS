//
//  CloudBackupConfiguring.swift
//  PlatformKit
//
//  Created by Paulo on 31/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol CloudBackupConfiguring: AnyObject {
    var cloudBackupEnabled: Bool { get set }
}
