// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureProductsDomain

/// A DTO representing multiple products as returned by the BE API.
/// - Note: Needs to be public to be able to make the APIClient interface public.
public struct ProductsAPIResponse: Codable, Hashable {

    public let buy: TradingProduct
    public let swap: TradingProduct
    public let custodialWallets: CustodialWalletProduct
}
