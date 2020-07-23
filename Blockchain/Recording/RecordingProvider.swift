//
//  RecordingProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import ToolKit

final class RecordingProvider: RecordingProviderAPI {
    
    // MARK: - Properties
    
    static let `default`: RecordingProviderAPI = RecordingProvider()
    
    let message: MessageRecording
    let error: ErrorRecording
    let analytics: AnalyticsEventRecorderAPI
    
    // MARK: - Setup
    
    init(message: MessageRecording = CrashlyticsRecorder(),
         error: ErrorRecording = CrashlyticsRecorder(),
         analytics: AnalyticsEventRecorderAPI = resolve()) {
        self.message = message
        self.error = error
        self.analytics = analytics
    }
}
