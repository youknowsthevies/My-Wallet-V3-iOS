//
//  SelectionScreenPresenter.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 30/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import PlatformKit

public final class SelectionScreenPresenter {
    
    // MARK: - Properties
    
    let title: String
    var presenters: Observable<[SelectionItemViewPresenter]> {
        return presentersRelay.asObservable()
    }
    
    private let presentersRelay = BehaviorRelay<[SelectionItemViewPresenter]>(value: [])
    
    let selectionRelay = PublishRelay<Int>()
    let deselectionRelay = PublishRelay<Int>()
    
    private let interactor: SelectionScreenInteractor
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(title: String, interactor: SelectionScreenInteractor) {
        self.title = title
        self.interactor = interactor
        interactor.interactors
            .map { interactors in
                interactors.map { SelectionItemViewPresenter(interactor: $0) }
            }
            .bind(to: presentersRelay)
            .disposed(by: disposeBag)
        
        selectionRelay
            .flatMap(weak: self) { (self, index) -> Observable<SelectionItemViewPresenter> in
                self.presenters.map { $0[index] }
            }
            .bind { presenter in
                presenter.select()
            }
            .disposed(by: disposeBag)
        
        deselectionRelay
            .flatMap(weak: self) { (self, index) -> Observable<SelectionItemViewPresenter> in
                self.presenters.map { $0[index] }
            }
            .bind { presenter in
                presenter.deselect()
            }
            .disposed(by: disposeBag)
    }
    
    func viewDidLoad() {
        Observable
            .zip(
                presenters.take(1),
                interactor.service.selectedDataRelay.take(1)
            )
            .compactMap { (presenters, selectedData) in
                presenters.firstIndex { $0.data == selectedData }
            }
            .bind(to: selectionRelay)
            .disposed(by: disposeBag)
    }
    
    func navigationBarLeadingButtonTapped() {
        interactor.recordSelection()
    }
}
