//
//  CaptureOutputProtocol.swift
//  PlatformUIKit
//
//  Created by Paulo on 25/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import AVKit

protocol CaptureOutputProtocol: AnyObject {
    var current: AVCaptureOutput? { get }
}

extension AVCaptureOutput: CaptureOutputProtocol {
    var current: AVCaptureOutput? { self }
}
