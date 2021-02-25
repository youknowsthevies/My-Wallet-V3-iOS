//
//  CaptureInputProtocol.swift
//  PlatformUIKit
//
//  Created by Paulo on 25/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import AVKit

public protocol CaptureInputProtocol: AnyObject {
    var current: AVCaptureInput? { get }
}

extension AVCaptureInput: CaptureInputProtocol {
    public var current: AVCaptureInput? { self }
}
