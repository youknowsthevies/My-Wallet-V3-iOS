// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

public struct Asset {
    let name: String
    let creator: String
    let tokenID: String
    let contractAddress: String
    let nftDescription: String
    let identifier: Int
    let collection: AssetCollection
    let media: Media
    let offers: [Offer]
    let owners: [String]
    let traits: [String]

    public struct Media {
        public init(
            backgroundColor: String,
            animationURL: URL,
            imageOriginalURL: URL,
            imagePreviewURL: URL,
            imageThumbnailURL: URL,
            imageURL: URL,
            largeImageURL: URL
        ) {
            self.backgroundColor = backgroundColor
            self.animationURL = animationURL
            self.imageOriginalURL = imageOriginalURL
            self.imagePreviewURL = imagePreviewURL
            self.imageThumbnailURL = imageThumbnailURL
            self.imageURL = imageURL
            self.largeImageURL = largeImageURL
        }

        let backgroundColor: String
        let animationURL: URL
        let imageOriginalURL: URL
        let imagePreviewURL: URL
        let imageThumbnailURL: URL
        let imageURL: URL
        let largeImageURL: URL
    }

    public init(
        name: String,
        creator: String,
        tokenID: String,
        contractAddress: String,
        nftDescription: String,
        identifier: Int,
        collection: AssetCollection,
        media: Media,
        offers: [Offer],
        owners: [String],
        traits: [String]
    ) {
        self.name = name
        self.creator = creator
        self.tokenID = tokenID
        self.contractAddress = contractAddress
        self.nftDescription = nftDescription
        self.identifier = identifier
        self.collection = collection
        self.media = media
        self.offers = offers
        self.owners = owners
        self.traits = traits
    }
}
