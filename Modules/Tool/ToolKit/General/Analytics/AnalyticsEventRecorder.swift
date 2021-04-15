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
    
    private let analyticsService: AnalyticsServiceAPI
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(analyticsService: AnalyticsServiceAPI = resolve()) {
        self.analyticsService = analyticsService
        
        recordRelay
            .subscribe(onNext: { [weak self] event in
                self?.record(event: event)
            })
            .disposed(by: disposeBag)
    }

    func record(event: AnalyticsEvent) {
        analyticsService.trackEvent(title: event.name, parameters: event.params)
    }
}
