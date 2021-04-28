//
//  AnalyticsEventRecorder.swift
//  PlatformKit
//
//  Created by Jack on 03/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Foundation
import RxRelay
import RxSwift

public typealias AnalyticsEventRecorderAPI = AnalyticsEventRecording & AnalyticsEventRelayRecording

final class AnalyticsEventRecorder: AnalyticsEventRecorderAPI {

    // MARK: - Properties
    
    let recordRelay = PublishRelay<AnalyticsEvent>()
    
    private let analyticsServiceProviders: [AnalyticsServiceProviding]
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(analyticsServiceProviders: [AnalyticsServiceProviding] = resolve()) {
        self.analyticsServiceProviders = analyticsServiceProviders
        
        recordRelay
            .subscribe(onNext: { [weak self] event in
                self?.record(event: event)
            })
            .disposed(by: disposeBag)
    }

    func record(event: AnalyticsEvent) {
        analyticsServiceProviders
            .filter { $0.isEventSupported(event) }
            .forEach {
                $0.trackEvent(title: event.name, parameters: event.params)
            }
    }
}
