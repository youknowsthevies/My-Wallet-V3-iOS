// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Foundation
import MetadataKit
import NetworkKit
import ToolKit

enum DIKitMetadataTags {
    static let metadata = "Metadata"
}

extension DependencyContainer {

    // MARK: - MetadataDataKit Module

    public static var metadataDataKit = module {

        factory(tag: DIKitMetadataTags.metadata) { () -> RequestBuilder in
            // TODO: Load config from file
            RequestBuilder(
                config: Network.Config(
                    scheme: "https",
                    host: "api.blockchain.info",
                    code: "35e77459-723f-48b0-8c9e-6e9e8f54fbd3",
                    components: []
                )
            )
        }

        factory { () -> MetadataRepositoryAPI in
            MetadataRepository(client: DIKit.resolve())
        }

        factory { () -> MetadataClientAPI in
            MetadataClient(
                networkAdapter: DIKit.resolve(),
                requestBuilder: DIKit.resolve(tag: DIKitMetadataTags.metadata)
            )
        }
    }
}
