//
//  MockMessageRecorder.swift
//  PlatformUIKitTests
//
//  Created by Paulo on 20/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ToolKit

final class MockMessageRecorder: MessageRecording {
    func record(_ message: String) {}
    func record() {}
}
