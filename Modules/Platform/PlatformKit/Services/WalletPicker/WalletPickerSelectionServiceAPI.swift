// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxRelay
import RxSwift

public protocol WalletPickerSelectionServiceAPI: class {
    var selectedData: Observable<BlockchainAccount> { get }
    func record(selection: BlockchainAccount)
}

public final class WalletPickerSelectionService: WalletPickerSelectionServiceAPI {

    public var selectedData: Observable<BlockchainAccount> {
        sharedStream
    }

    private var sharedStream: Observable<BlockchainAccount>!
    private let defaultValue: Observable<AccountGroup>
    private let selectedDataRelay: BehaviorRelay<BlockchainAccount?>
    private let coincore: Coincore

    public init(coincore: Coincore = resolve()) {
        self.coincore = coincore
        defaultValue = coincore.allAccounts.asObservable().share(replay: 1)
        selectedDataRelay = BehaviorRelay(value: nil)
        sharedStream = selectedDataRelay
            .flatMapLatest(weak: self) { (self, account) -> Observable<BlockchainAccount> in
                guard let account = account else {
                    return self.defaultValue.map { $0 as BlockchainAccount }
                }
                return .just(account)
            }
            .distinctUntilChanged(\.id)
            .share(replay: 1)
    }

    public func record(selection: BlockchainAccount) {
        selectedDataRelay.accept(selection)
    }
}
