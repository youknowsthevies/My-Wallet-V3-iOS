//
//  SellTransferCancellationRoutingInteractor.swift
//  BuySellUIKit
//
//  Created by Alex McGregor on 8/28/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxRelay
import RxSwift
import ToolKit

public final class SellTransferCancellationRoutingInteractor: TransferOrderRoutingInteracting {
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    
    private lazy var setup: Void = {
        nextRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                self.routingInteractor.orderCompleted()
            }
            .disposed(by: disposeBag)
        
        previousRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                self.routingInteractor.previousRelay.accept(())
                self.analyticsRecorder.record(event: AnalyticsEvent.sbCancelOrderGoBack)
            }
            .disposed(by: disposeBag)
    }()
    
    public let nextRelay = PublishRelay<Void>()
    public let previousRelay = PublishRelay<Void>()
    public let analyticsRecorder: AnalyticsEventRecording
    
    private let disposeBag = DisposeBag()
    private unowned let routingInteractor: SellRouterInteractor
    
    public init(routingInteractor: SellRouterInteractor,
                analyticsRecording: AnalyticsEventRecording = resolve()) {
        self.analyticsRecorder = analyticsRecording
        self.routingInteractor = routingInteractor
        _ = setup
    }
}
