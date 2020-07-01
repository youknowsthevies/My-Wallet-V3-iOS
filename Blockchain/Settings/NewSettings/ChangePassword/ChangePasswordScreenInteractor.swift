//
//  ChangePasswordScreenInteractor.swift
//  Blockchain
//
//  Created by AlexM on 3/11/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

final class ChangePasswordScreenInteractor {
    
    enum State {
        case unknown
        case ready
        case updating
        case passwordUnknown
        case incorrectPassword
        case complete
        case failed
        
        var isLoading: Bool {
            switch self {
            case .updating:
                return true
            default:
                return false
            }
        }
        
        var isComplete: Bool {
            switch self {
            case .complete:
                return true
            default:
                return false
            }
        }
    }
    
    struct InteractorInput {
        let currentPassword: String
        let newPassword: String
    }
    
    let triggerRelay = PublishRelay<Void>()
    let contentRelay: BehaviorRelay<InteractorInput> = BehaviorRelay(value: .empty)
    var state: Observable<State> {
        stateRelay.asObservable()
    }
    
    // MARK: - Injected
    
    private let stateRelay = BehaviorRelay<State>(value: .unknown)
    private let currentPasswordRelay = BehaviorRelay<String>(value: "")
    private let passwordRepository: PasswordRepositoryAPI
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    init(passwordAPI: PasswordRepositoryAPI = WalletManager.shared.repository) {
        self.passwordRepository = passwordAPI
        
        passwordRepository.hasPassword
            .observeOn(MainScheduler.instance)
            .map { hasPassword -> State in
                hasPassword ? .passwordUnknown : .ready
            }
            .subscribe(onSuccess: { [weak self] state in
                guard let self = self else { return }
                self.stateRelay.accept(state)
            })
            .disposed(by: disposeBag)
            
        passwordRepository.password.asObservable()
            .compactMap { $0 }
            .bindAndCatch(to: currentPasswordRelay)
            .disposed(by: disposeBag)
        
        triggerRelay
            .bindAndCatch(weak: self) { (self) in
                self.changePassword()
            }
            .disposed(by: disposeBag)
    }
    
    private func changePassword() {
        let current = currentPasswordRelay.value
        let input = contentRelay.value
        guard current == input.currentPassword else {
            stateRelay.accept(.incorrectPassword)
            return
        }
        
        update(state: .updating)
            .andThen(passwordRepository.set(password: input.newPassword))
            .andThen(passwordRepository.sync())
            .subscribeOn(MainScheduler.instance)
            .subscribe(
                onCompleted: { [weak self] in
                    self?.stateRelay.accept(.complete)
                },
                onError: { [weak self] (error) in
                    self?.stateRelay.accept(.failed)
                })
            .disposed(by: disposeBag)
    }
    
    private func update(state: State) -> Completable {
        Completable.create { [weak self] (observer) -> Disposable in
            self?.stateRelay.accept(state)
            observer(.completed)
            return Disposables.create()
        }
    }
}

extension ChangePasswordScreenInteractor.InteractorInput {
    static let empty: ChangePasswordScreenInteractor.InteractorInput = .init(currentPassword: "", newPassword: "")
}
