// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation

extension DependencyContainer {

    // MARK: - MetadataKit Module

    public static var metadataKit = module {

        factory { () -> MetadataServiceAPI in
            let repository: MetadataRepositoryAPI = DIKit.resolve()
            let fetch = repository.fetch(at:)
            let put = repository.put(at:with:)
            return MetadataService(
                initialize: provideInitialize(fetch: fetch, put: put),
                initializeAndRecoverCredentials: provideInitializeAndRecoverCredentials(
                    fetch: fetch
                ),
                fetchEntry: provideFetchEntry(fetch: fetch),
                saveEntry: provideSave(fetch: fetch, put: put)
            )
        }
    }
}
