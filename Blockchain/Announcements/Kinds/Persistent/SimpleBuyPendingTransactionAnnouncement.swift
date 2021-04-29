//
//  SimpleBuyPendingTransactionAnnouncement.swift
//  Blockchain
//
//  Created by Paulo on 30/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import AnalyticsKit
import BuySellKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

final class SimpleBuyPendingTransactionAnnouncement: PersistentAnnouncement & ActionableAnnouncement {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.SimpleBuyPendingTransaction

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizedString.ctaButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.action()
            }
            .disposed(by: disposeBag)

        let orderDetails = order!
        let assetCode = orderDetails.outputValue.currencyType.displayCode
        
        let imageName: String
        let title: String
        let description: String
        if orderDetails.isBankWire {
            title = "\(LocalizedString.titlePrefix) \(assetCode) \(LocalizedString.titleSuffix)"
            description = "\(LocalizedString.descriptionPrefix) \(assetCode) \(LocalizedString.descriptionSuffix)"
            imageName = "clock-error-icon"
        } else {
            title = ""
            description = ""
            imageName = "icon-card"
        }
        
        return AnnouncementCardViewModel(
            type: type,
            image: AnnouncementCardViewModel.Image(
                name: imageName,
                size: CGSize(width: 27, height: 27),
                tintColor: .iconWarning,
                bundle: .platformUIKit
            ),
            title: title,
            description: description,
            buttons: [button],
            dismissState: .undismissible,
            didAppear: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.didAppearAnalyticsEvent)
            }
        )
    }

    var shouldShow: Bool {
        guard let order = order else {
            return false
        }
        // Shows only for bank wire - we need copy for card orders
        return order.isBankWire && order.state == .pendingDeposit
    }

    let type = AnnouncementType.simpleBuyPendingTransaction
    let analyticsRecorder: AnalyticsEventRecording

    let action: CardAnnouncementAction

    private let order: OrderDetails?

    private let disposeBag = DisposeBag()
    // MARK: - Setup

    init(order: OrderDetails?,
         analyticsRecorder: AnalyticsEventRecording = resolve(),
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         action: @escaping CardAnnouncementAction) {
        self.order = order
        self.action = action
        self.analyticsRecorder = analyticsRecorder
    }
}

