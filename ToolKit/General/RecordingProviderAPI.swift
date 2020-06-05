//
//  RecordingProviderAPI.swift
//  ToolKit
//
//  Created by Daniel Huri on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public protocol RecordingProviderAPI: AnyObject {
    var message: MessageRecording { get }
    var error: ErrorRecording { get }
    var analytics: AnalyticsEventRecording & AnalyticsEventRelayRecording { get }
}
