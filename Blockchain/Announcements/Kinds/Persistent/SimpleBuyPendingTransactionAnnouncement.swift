//
//  SimpleBuyPendingTransactionAnnouncement.swift
//  Blockchain
//
//  Created by Paulo on 30/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import ToolKit
import PlatformKit
import PlatformUIKit

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
        let assetCode = orderDetails.cryptoValue.currencyType.displayCode
        
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
            recorder: errorRecorder,
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

    private let order: SimpleBuyOrderDetails?

    private let disposeBag = DisposeBag()
    private let errorRecorder: ErrorRecording

    // MARK: - Setup

    init(order: SimpleBuyOrderDetails?,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         action: @escaping CardAnnouncementAction) {
        self.order = order
        self.errorRecorder = errorRecorder
        self.action = action
        self.analyticsRecorder = analyticsRecorder
    }
}

