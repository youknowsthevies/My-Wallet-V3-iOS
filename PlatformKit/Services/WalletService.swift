//
//  WalletService.swift
//  PlatformKit
//
//  Created by AlexM on 8/7/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import RxSwift

class WalletService: WalletOptionsAPI {
    
    // MARK: - Private Properties
    
    private(set) var cachedWalletOptions = Variable<WalletOptions?>(nil)
    
    private var networkFetchedWalletOptions: Single<WalletOptions> {
        guard let url = URL(string: BlockchainAPI.shared.walletOptionsUrl) else {
            return Single.error(NetworkCommunicatorError.clientError(.failedRequest(description: "Invalid URL")))
        }
        return communicator
            .perform(request: NetworkRequest(endpoint: url, method: .get))
            .do(onSuccess: { [weak self] in
                self?.cachedWalletOptions.value = $0
            })
    }
    
    private let communicator: NetworkCommunicatorAPI
    
    // MARK: - Public
    
    init(communicator: NetworkCommunicatorAPI = resolve()) {
        self.communicator = communicator
    }
    
    /// A Single returning the WalletOptions which contains dynamic flags for configuring the app.
    /// If WalletOptions has already been fetched, this property will return the cached value
    var walletOptions: Single<WalletOptions> {
        Single.deferred { [unowned self] in
            guard let cachedValue = self.cachedWalletOptions.value else {
                return self.networkFetchedWalletOptions
            }
            return Single.just(cachedValue)
        }
    }
    
    var serverUnderMaintenanceMessage: Single<String?> {
        walletOptions.map { options in
            if options.downForMaintenance {
                // TODO
                return options.mobileInfo?.message ?? ""
            } else {
                return nil
            }
        }
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
}
