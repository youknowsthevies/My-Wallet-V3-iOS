// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit

final class AssetPriceCellPresenter {

    let currency: CryptoCurrency
    let priceViewPresenter: TodayAssetPriceViewPresenter
    let thumbnailContent: ImageViewContent
    let titleLabelContent: LabelContent
    let descriptionLabelContent: LabelContent
    private let interactor: AssetPriceCellInteractor

    init(interactor: AssetPriceCellInteractor) {
        self.interactor = interactor
        currency = interactor.currency
        // TODO: Accessibility
        priceViewPresenter = TodayAssetPriceViewPresenter(
            interactor: interactor.priceViewInteractor,
            alignment: .trailing
        )
        let localImage = currency.logoResource.local
        thumbnailContent = ImageViewContent(
            imageName: localImage.name,
            bundle: localImage.bundle
        )
        titleLabelContent = .init(
            text: currency.name,
            font: .systemFont(ofSize: 16.0, weight: .semibold),
            color: .white,
            alignment: .left,
            accessibility: .none
        )
        descriptionLabelContent = .init(
            text: currency.code,
            font: .systemFont(ofSize: 12.0, weight: .semibold),
            color: .descriptionText,
            alignment: .left,
            accessibility: .none
        )
    }
}
