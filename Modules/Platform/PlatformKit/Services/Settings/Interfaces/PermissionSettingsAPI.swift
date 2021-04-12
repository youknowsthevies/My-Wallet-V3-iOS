//
//  PermissionSettingsAPI.swift
//  PlatformKit
//
//  Created by Paulo on 05/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol PermissionSettingsAPI: AnyObject {

    var didRequestCameraPermissions: Bool { get set }

    var didRequestMicrophonePermissions: Bool { get set }

    var didRequestNotificationPermissions: Bool { get set }
}
