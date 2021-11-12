import Combine
import RxSwift

extension Publisher {

    public func asObservable() -> Observable<Output> {
        Observable.create { [self] observer in
            let subscription = sink { completion in
                switch completion {
                case .finished:
                    observer.on(.completed)
                case .failure(let error):
                    observer.on(.error(error))
                }
            } receiveValue: { output in
                observer.on(.next(output))
            }
            return Disposables.create {
                subscription.cancel()
            }
        }
    }
}
