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

        factory { Metadata.Config.default() }

        factory(tag: DIKitMetadataTags.metadata) { () -> Network.Config in
            Network.Config.metadata()
        }

        factory(tag: DIKitMetadataTags.metadata) { () -> RequestBuilder in
            RequestBuilder.metadataBuilder()
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

extension Metadata.Config {

    fileprivate static func `default`(
        code: APICode = resolve()
    ) -> Metadata.Config {
        Metadata.Config(
            host: InfoDictionaryHelper.value(for: .apiURL),
            code: code
        )
    }
}

extension Network.Config {

    fileprivate static func metadata(
        config: Metadata.Config = resolve()
    ) -> Network.Config {
        Network.Config(
            scheme: "https",
            host: config.host,
            code: config.code,
            components: []
        )
    }
}

extension RequestBuilder {

    fileprivate static func metadataBuilder(
        config: Network.Config = resolve(tag: DIKitMetadataTags.metadata)
    ) -> RequestBuilder {
        RequestBuilder(config: config)
    }
}
