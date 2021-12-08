// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation

extension DependencyContainer {

    // MARK: - MetadataKit Module

    public static var metadataKit = module {

        factory { () -> MetadataServiceAPI in
            let repository: MetadataRepositoryAPI = DIKit.resolve()
            let fetch = repository.fetch(at:)
            return MetadataService(
                loadMetadata: loadRemoteMetadata(
                    fetchMetadataEntry: fetch
                )
            )
        }
    }
}
