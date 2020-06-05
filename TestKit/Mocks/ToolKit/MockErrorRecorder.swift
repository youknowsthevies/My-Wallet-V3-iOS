//
//  AnnouncementRecorderTests.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 6/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import ToolKit

class MockErrorRecorder: ErrorRecording {
    func error(_ error: Error) {}
    func error(_ errorMessage: String) {}
    func error() {}
}