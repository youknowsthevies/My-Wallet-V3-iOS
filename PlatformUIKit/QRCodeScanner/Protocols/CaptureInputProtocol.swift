//
//  CaptureInputProtocol.swift
//  PlatformUIKit
//
//  Created by Paulo on 25/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import AVKit

protocol CaptureInputProtocol: AnyObject {
    var current: AVCaptureInput? { get }
}

extension AVCaptureInput: CaptureInputProtocol {
    var current: AVCaptureInput? { self }
}
