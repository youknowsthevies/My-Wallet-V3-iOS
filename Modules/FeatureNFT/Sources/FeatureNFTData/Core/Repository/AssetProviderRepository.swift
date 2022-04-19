// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureNFTDomain
import Foundation
import NabuNetworkError
import NetworkKit
import ToolKit

public final class AssetProviderRepository: AssetProviderRepositoryAPI {

    private let client: FeatureNFTClientAPI

    public init(client: FeatureNFTClientAPI) {
        self.client = client
    }

    // MARK: - AssetProviderRepositoryAPI

    public func fetchAssetsFromEthereumAddress(
        _ address: String
    ) -> AnyPublisher<[Asset], NabuNetworkError> {
        client
            .fetchAssetsFromEthereumAddress(address)
            .map { $0.map(Asset.init(response:)) }
            .eraseToAnyPublisher()
    }
}

extension Asset {
    init(response: AssetResponse) {
        self = .init(
            name: response.name,
            creator: response.creator,
            tokenID: response.tokenID,
            contractAddress: response.assetContract.address,
            nftDescription: response.nftDescription,
            identifier: response.identifier,
            collection: .init(response: response.collection),
            media: .init(response: response),
            offers: response.offers.map(Offer.init(response:)),
            owners: response.owners,
            traits: response.traits
        )
    }
}

extension AssetCollection {
    init(response: CollectionResponse) {
        self = .init(
            name: response.name,
            collectionDescription: response.collectionDescription,
            payoutAddress: response.payoutAddress,
            shortDescription: response.shortDescription,
            slug: response.slug,
            createdDate: response.createdDate,
            externalURL: response.externalURL,
            featured: response.featured,
            hidden: response.hidden,
            stats: response.stats
        )
    }
}

extension Asset.Media {
    init(response: AssetResponse) {
        self = .init(
            backgroundColor: response.backgroundColor,
            animationURL: response.animationURL,
            imageOriginalURL: response.imageOriginalURL,
            imagePreviewURL: response.imagePreviewURL,
            imageThumbnailURL: response.imageThumbnailURL,
            imageURL: response.imageURL,
            largeImageURL: response.largeImageURL
        )
    }
}

extension Offer {
    init(response: OfferResponse) {
        self = .init(
            devSellerFeeBasisPoints: response.devSellerFeeBasisPoints,
            identifier: response.identifier,
            createdDate: response.createdDate,
            bidAmount: response.bidAmount,
            collectionSlug: response.collectionSlug,
            contractAddress: response.contractAddress,
            eventType: response.eventType,
            quantity: response.quantity
        )
    }
}
