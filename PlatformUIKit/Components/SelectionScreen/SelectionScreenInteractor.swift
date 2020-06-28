//
//  SelectionScreenInteractor.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 31/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

public final class SelectionScreenInteractor {
        
    // MARK: - Properties
    
    private let interactorsRelay = BehaviorRelay<[SelectionItemViewInteractor]>(value: [])
    var interactors: Observable<[SelectionItemViewInteractor]> {
        interactorsRelay.asObservable()
    }
    
    public var selectedIdOnDismissal: Single<String> {
        selectionOnDismissalRelay
            .take(1)
            .asSingle()
            .map { $0.id }
    }
    
    public var dismiss: Observable<Void> {
        dissmisRelay.asObservable()
    }
    
    let dissmisRelay = PublishRelay<Void>()
    
    private let selectionOnDismissalRelay = PublishRelay<SelectionItemViewModel>()
    
    // MARK: - Injected
    
    let service: SelectionServiceAPI
    
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(service: SelectionServiceAPI) {
        self.service = service
        
        let interactors = service.dataSource
            .map { items in
                items
                    .sorted()
                    .map { item in
                        SelectionItemViewInteractor(
                            item: item,
                            service: service
                        )
                    }
            }
            .share(replay: 1)

        interactors
            .bindAndCatch(to: interactorsRelay)
            .disposed(by: disposeBag)
    }
    
    func recordSelection() {
        service.selectedDataRelay
            .bindAndCatch(to: selectionOnDismissalRelay)
            .disposed(by: disposeBag)
    }
}
