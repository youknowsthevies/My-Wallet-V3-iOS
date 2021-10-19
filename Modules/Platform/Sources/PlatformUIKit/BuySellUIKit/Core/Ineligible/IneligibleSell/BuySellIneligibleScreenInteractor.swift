// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

public final class BuySellIneligibleScreenInteractor {

    // MARK: - Public

    var region: Single<String> {
        dataRepositoryAPI.user
            .map(\.address?.state)
            .replaceNil(with: Country.current?.name ?? Country.US.name)
            .asSingle()
    }

    // MARK: - Injected

    private let dataRepositoryAPI: DataRepositoryAPI

    // MARK: - Init

    init(dataRepositoryAPI: DataRepositoryAPI = resolve()) {
        self.dataRepositoryAPI = dataRepositoryAPI
    }
}
