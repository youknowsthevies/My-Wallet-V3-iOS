// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

protocol SupportedAssetsRepositoryAPI {
    var erc20Assets: SupportedAssets { get }
}

final class SupportedAssetsRepository: SupportedAssetsRepositoryAPI {

    let localService: SupportedAssetsLocalServiceAPI
    private(set) lazy var erc20Assets: SupportedAssets = {
        switch localService.erc20Asset {
        case .success(let response):
            return SupportedAssets(response: response)
        case .failure(let error):
            #if INTERNAL_BUILD
            fatalError("Can' load local ERC20 assets. \(error.localizedDescription)")
            #else
            return SupportedAssets.empty
            #endif
        }
    }()

    init(localService: SupportedAssetsLocalServiceAPI = resolve()) {
        self.localService = localService
    }
}
