//
//  ActivityMessageViewModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/17/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit
import PlatformKit
import PlatformUIKit

final class ActivityMessageViewModel {
    
    let titleLabelContent: LabelContent
    let descriptionLabelContent: LabelContent
    let cryptoAmountLabelContent: LabelContent
    let sharedWithLabelContent: LabelContent
    let image: UIImage?
    let logoImage: ImageViewContent
    let badgeImageViewModel: BadgeImageViewModel
    
    init?(event: ActivityItemEvent,
          qrCodeAPI: QRCodeWrapperAPI,
          blockchainAPI: BlockchainAPI = .shared) {
        guard case let .transactional(transaction) = event else { return nil }
        var title = ""
        var imageName = ""
        let currency = transaction.currency
        switch transaction.type {
        case .send:
            title = "\(LocalizationConstants.Activity.MainScreen.Item.send) \(currency.name)"
            imageName = "send-icon"
        case .receive:
            title = "\(LocalizationConstants.Activity.MainScreen.Item.receive) \(currency.name)"
            imageName = "receive-icon"
        }
        
        sharedWithLabelContent = .init(
            text: LocalizationConstants.Activity.MainScreen.MessageView.sharedWithBlockchain,
            font: .main(.semibold, 8.0),
            color: .descriptionText,
            accessibility: .none
        )
        
        badgeImageViewModel = .template(
            with: imageName,
            templateColor: currency.brandColor,
            backgroundColor: currency.brandColor.withAlphaComponent(0.15),
            accessibilityIdSuffix: ""
        )
        badgeImageViewModel.marginOffsetRelay.accept(0.0)
        
        titleLabelContent = .init(
            text: title,
            font: .main(.semibold, 16.0),
            color: .textFieldText,
            alignment: .left,
            accessibility: .none
        )
        
        descriptionLabelContent = .init(
            text: DateFormatter.medium.string(from: event.creationDate),
            font: .main(.medium, 14.0),
            color: .descriptionText,
            alignment: .left,
            accessibility: .none
        )
        
        guard let url = blockchainAPI.transactionDetailURL(for: event.identifier, cryptoCurrency: transaction.currency) else { return nil }
        image = qrCodeAPI.qrCode(from: url)?.image
        logoImage = .init(
            imageName: "logo-blockchain",
            accessibility: .none,
            renderingMode: .normal,
            bundle: .main
        )
        cryptoAmountLabelContent = .init(
            text: event.amount.toDisplayString(includeSymbol: true),
            font: .main(.semibold, 14.0),
            color: .descriptionText,
            alignment: .left,
            accessibility: .none
        )
    }
}
