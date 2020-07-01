//
//  AnnouncementRecorderTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 6/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import XCTest

class MockErrorRecorder: ErrorRecording {
    func error(_ error: Error) { }
}
