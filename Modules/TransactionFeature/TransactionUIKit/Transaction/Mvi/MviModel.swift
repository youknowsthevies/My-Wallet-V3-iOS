// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class MviModel<State, Action: MviAction> where Action.State == State, State: Equatable {

    lazy var state: Observable<State> = {
        stateRelay
            .distinctUntilChanged()
            .asObservable()
    }()

    let actions: ReplaySubject<Action> = ReplaySubject.create(bufferSize: 1)

    private var disposeBag = DisposeBag()

    private let stateRelay: BehaviorRelay<State>
    private let performAction: (State, Action) -> Disposable?

    init(initialState: State, performAction: @escaping (State, Action) -> Disposable?) {
        stateRelay = BehaviorRelay(value: initialState)
        self.performAction = performAction
        actions // TODO: Inject // actions.distinctUntilChanged()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .scan(initialState) { [unowned self] (oldState, action) -> State in
                guard action.isValid(for: oldState) else {
                    return oldState
                }
                self.performAction(oldState, action)?
                    .disposed(by: self.disposeBag)
                return action.reduce(oldState: oldState)
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }

    func process(action: Action) {
        actions.on(.next(action))
    }

    func destroy() {
        disposeBag = DisposeBag()
    }
}
