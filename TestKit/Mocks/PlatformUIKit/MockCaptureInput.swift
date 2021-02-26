//
//  MockCaptureInput.swift
//  TestKit
//
//  Created by Paulo on 25/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import AVKit
@testable import PlatformUIKit

final class MockCaptureInput: CaptureInputProtocol {
    var current: AVCaptureInput?
}
