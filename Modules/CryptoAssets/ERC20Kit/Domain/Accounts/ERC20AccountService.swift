// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

protocol ERC20AccountServiceAPI {
    
    /// Checks if the provided `address` is a contract address
    /// - Parameter address: the ethereum address to check
    func isContract(address: String) -> Single<Bool>
}

final class ERC20AccountService<Token: ERC20Token>: ERC20AccountServiceAPI {
    
    private let addresses: Atomic<[String: Bool]>
    private let accountClient: AnyERC20AccountAPIClient<Token>

    init<APIClient: ERC20AccountAPIClientAPI>(
        accountClient: APIClient = resolve(),
        addressLookupCache: Atomic<[String: Bool]> = resolve(
            tag: DependencyContainer.Tags.ERC20AccountService.addressCache
        )
    ) where APIClient.Token == Token {
        self.accountClient = AnyERC20AccountAPIClient(
            accountAPIClient: accountClient
        )
        self.addresses = addressLookupCache
    }
    
    init(accountClient: AnyERC20AccountAPIClient<Token> = resolve(),
         addressLookupCache: Atomic<[String: Bool]> = resolve(
            tag: DependencyContainer.Tags.ERC20AccountService.addressCache
         )
    ) {
        self.accountClient = accountClient
        self.addresses = addressLookupCache
    }
    
    func isContract(address: String) -> Single<Bool> {
        guard let isContractAddress = addresses.value[address] else {
            return accountClient
                .isContract(address: address)
                .map(\.contract)
                .do(onSuccess: { [weak self] isContractAddress in
                    self?.addresses.mutate { addresses in
                        addresses[address] = isContractAddress
                    }
                })
        }
        return .just(isContractAddress)
    }
}
