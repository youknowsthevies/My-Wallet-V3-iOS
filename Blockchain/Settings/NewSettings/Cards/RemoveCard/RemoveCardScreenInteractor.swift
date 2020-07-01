//
//  RemoveCardScreenInteractor.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/9/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class RemoveCardScreenInteractor {
    
    typealias InteractorInput = String
    
    enum State {
        /// Interactor is ready
        case ready
        
        /// Request in flight
        case executing
        
        /// Deletion complete
        case complete
        
        /// Update failed
        case failed
        
        var isExecuting: Bool {
            self == .executing
        }
    }
    
    let triggerRelay = PublishRelay<Void>()
    let contentRelay: BehaviorRelay<InteractorInput> = BehaviorRelay(value: "")
    
    var state: Observable<State> {
        stateRelay.asObservable()
    }
    
    private let stateRelay = BehaviorRelay<State>(value: .ready)
    private let deletionService: CardDeletionServiceAPI
    private let cardListService: CardListServiceAPI
    private let disposeBag = DisposeBag()
    private let eventRecorder: AnalyticsEventRecording
    
    init(cardListService: CardListServiceAPI,
         deletionService: CardDeletionServiceAPI,
         eventRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared) {
        self.cardListService = cardListService
        self.deletionService = deletionService
        self.eventRecorder = eventRecorder
        
        // Analytics
        stateRelay
            .filter { $0 == .complete }
            .mapToVoid()
            .record(analyticsEvent: AnalyticsEvents.SimpleBuy.sbRemoveCard, using: eventRecorder)
            .subscribe()
            .disposed(by: disposeBag)
        
        triggerRelay
            .withLatestFrom(contentRelay)
            .flatMap(weak: self) { (self, cardId) -> Observable<State> in
                self.delete(cardId: cardId)
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
    
    private func delete(cardId: String) -> Observable<State> {
        deletionService.deleteCard(by: cardId)
            .andThen(cardListService.fetchCards())
            .asObservable()
            .mapToVoid()
            .map { State.complete }
            .startWith(State.executing)
            .catchErrorJustReturn(State.failed)
    }
}
