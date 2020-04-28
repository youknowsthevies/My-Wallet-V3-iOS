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

        let assetCode = assetType?.displayCode ?? ""
        return AnnouncementCardViewModel(
            type: type,
            image: AnnouncementCardViewModel.Image(
                name: "clock-error-icon",
                size: CGSize(width: 27, height: 27),
                tintColor: .iconWarning,
                bundle: .platformUIKit
            ),
            title: "\(LocalizedString.titlePrefix) \(assetCode) \(LocalizedString.titleSuffix)",
            description: "\(LocalizedString.descriptionPrefix) \(assetCode) \(LocalizedString.descriptionSuffix)",
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
        return assetType != nil
    }

    let type = AnnouncementType.simpleBuyPendingTransaction
    let analyticsRecorder: AnalyticsEventRecording

    let action: CardAnnouncementAction

    private let assetType: CryptoCurrency?

    private let disposeBag = DisposeBag()
    private let errorRecorder: ErrorRecording

    // MARK: - Setup

    init(hasPendingTransactionFor assetType: CryptoCurrency?,
         analyticsRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         errorRecorder: ErrorRecording = CrashlyticsRecorder(),
         action: @escaping CardAnnouncementAction) {
        self.assetType = assetType
        self.errorRecorder = errorRecorder
        self.action = action
        self.analyticsRecorder = analyticsRecorder
    }
}

