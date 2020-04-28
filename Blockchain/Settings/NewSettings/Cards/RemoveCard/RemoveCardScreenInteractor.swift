//
//  RemoveCardScreenInteractor.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/9/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import ToolKit
import PlatformKit

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
    
    var triggerRelay = PublishRelay<Void>()
    let contentRelay: BehaviorRelay<InteractorInput> = BehaviorRelay(value: "")
    var state: Observable<State> {
        stateRelay.asObservable()
    }
    
    private let stateRelay = BehaviorRelay<State>(value: .ready)
    private let cardListService: CardListServiceAPI
    private let deletionService: CardDeletionServiceAPI
    private let disposeBag = DisposeBag()
    private let eventRecorder: AnalyticsEventRecording
    
    init(service: CardDeletionServiceAPI,
         cardListService: CardListServiceAPI,
         eventRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared) {
        self.deletionService = service
        self.cardListService = cardListService
        self.eventRecorder = eventRecorder
        
        triggerRelay
            .bind(weak: self) { (self, _) in
                self.delete()
            }
            .disposed(by: disposeBag)
    }
    
    private func delete() {
        update(state: .executing)
            .andThen(deletionService.deleteCard(by: contentRelay.value))
            .andThen(cardListService.fetchCards())
            .subscribe(onSuccess: { [weak self] _ in
                guard let self = self else { return }
                self.eventRecorder.record(event: AnalyticsEvents.SimpleBuy.sbRemoveCard)
                self.stateRelay.accept(.complete)
            }, onError: { [weak self] _ in
                self?.stateRelay.accept(.failed)
            })
            .disposed(by: disposeBag)
    }
    
    private func update(state: State) -> Completable {
        return Completable.create { [weak self] (observer) -> Disposable in
            self?.stateRelay.accept(state)
            observer(.completed)
            return Disposables.create()
        }
    }
}
