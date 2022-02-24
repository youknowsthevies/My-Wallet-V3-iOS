// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import ToolKit

/// Type alias representing fees data for specific crypto currencies.
public typealias CryptoFeeType = TransactionFee & Decodable

/// Service that provides fees of its associated type.
public protocol CryptoFeeServiceAPI {
    associatedtype FeeType: CryptoFeeType

    /// Streams a single CryptoFeeType of the associated type.
    /// This represent current fees to transact a crypto currency.
    /// Never fails, uses default Fee values if network call fails.
    var fees: AnyPublisher<FeeType, Never> { get }
}

public final class CryptoFeeService<FeeType: TransactionFee & Decodable>: CryptoFeeServiceAPI {

    // MARK: - CryptoFeeServiceAPI

    public var fees: AnyPublisher<FeeType, Never> {
        client.fees
            .handleEvents(receiveCompletion: { status in
                guard case .failure(let error) = status else {
                    return
                }
                Logger.shared.error(error)
            })
            .replaceError(with: FeeType.default)
            .eraseToAnyPublisher()
    }

    // MARK: - Private Properties

    private let client: CryptoFeeClient<FeeType>

    // MARK: - Init

    init(client: CryptoFeeClient<FeeType>) {
        self.client = client
    }

    public convenience init() {
        self.init(client: CryptoFeeClient<FeeType>())
    }
}

/// Type-erasure for CryptoFeeService.
public struct AnyCryptoFeeService<FeeType: CryptoFeeType>: CryptoFeeServiceAPI {

    private let _fees: () -> AnyPublisher<FeeType, Never>
    public var fees: AnyPublisher<FeeType, Never> {
        _fees()
    }

    public init<API: CryptoFeeServiceAPI>(service: API) where API.FeeType == FeeType {
        _fees = { service.fees }
    }
}
