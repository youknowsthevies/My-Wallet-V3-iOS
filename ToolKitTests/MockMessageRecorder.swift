//
//  MockMessageRecorder.swift
//  ToolKitTests
//
//  Created by Daniel Huri on 02/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import ToolKit

final class MockMessageRecorder: MessageRecording {
    func record(_ message: String) {}
    func record() {}
}
