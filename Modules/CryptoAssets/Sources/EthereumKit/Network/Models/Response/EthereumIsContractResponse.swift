// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// An ethereum `isContract` service response.
struct EthereumIsContractResponse: Decodable {

    /// Whether the given ethereum address is associated with an ethereum smart contract.
    let contract: Bool
}
