//
//  WebLoginScreenPresenter.swift
//  Blockchain
//
//  Created by Paulo on 20/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxRelay
import RxSwift
import RxCocoa

final class WebLoginScreenPresenter {

    // MARK: - Types

    private typealias Strings = LocalizationConstants.Settings.WebLogin

    // MARK: - Public Properties

    let leadingButton: Screen.Style.LeadingButton = .back

    var titleView: Screen.Style.TitleView {
        .text(value: Strings.title)
    }

    var barStyle: Screen.Style.Bar {
        .darkContent(ignoresStatusBar: false, background: .white)
    }

    var qrCodeImage: Single<UIImage?> {
        service
            .qrCodeString
            .map { QRCode(string: $0) }
            .map { $0?.image }
            .catchErrorJustReturn(nil)
    }

    var qrCodeVisibility: Driver<Visibility> {
        return qrCodeVisibilityRelay.asDriver()
    }

    let step1Label: LabelContent
    let bullet1Label: LabelContent
    let step2Label: LabelContent
    let bullet2Label: LabelContent
    let step3Label: LabelContent
    let bullet3Label: LabelContent
    let securityAlert: LabelContent
    let qrCodeScurityAlertTop: LabelContent
    let qrCodeScurityAlertBottom: LabelContent
    let actionButtonModel: ButtonViewModel

    // MARK: - Private Properties

    private let qrCodeVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let service: WebLoginQRCodeServiceAPI
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(service: WebLoginQRCodeServiceAPI = WebLoginQRCodeService()) {
        self.service = service
        step1Label = .init(
            text: Strings.step1,
            font: .mainMedium(14),
            color: .descriptionText,
            accessibility: .none
        )
        bullet1Label = .init(
            text: "1",
            font: .mainBold(20),
            color: .titleText,
            alignment: .center,
            accessibility: .none
        )
        step2Label = .init(
            text: Strings.step2,
            font: .mainMedium(14),
            color: .descriptionText,
            accessibility: .none
        )
        bullet2Label = .init(
            text: "2",
            font: .mainBold(20),
            color: .titleText,
            alignment: .center,
            accessibility: .none
        )
        step3Label = .init(
            text: Strings.step3,
            font: .mainMedium(14),
            color: .descriptionText,
            accessibility: .none
        )
        bullet3Label = .init(
            text: "3",
            font: .mainBold(20),
            color: .titleText,
            alignment: .center,
            accessibility: .none
        )
        securityAlert = .init(
            text: Strings.securityMessageHidden,
            font: .mainMedium(14),
            color: .descriptionText,
            alignment: .center,
            accessibility: .none
        )
        qrCodeScurityAlertTop = .init(
            text: Strings.securityMessageVisible1,
            font: .mainMedium(14),
            color: .descriptionText,
            alignment: .center,
            accessibility: .none
        )
        qrCodeScurityAlertBottom = .init(
            text: Strings.securityMessageVisible2,
            font: .mainMedium(14),
            color: .descriptionText,
            alignment: .center,
            accessibility: .none
        )

        actionButtonModel = .primary(with: Strings.hideQRCode)

        qrCodeVisibilityRelay
            .asDriver()
            .map { $0 == .visible ? Strings.hideQRCode : Strings.showQRCode }
            .drive(actionButtonModel.textRelay)
            .disposed(by: disposeBag)

        qrCodeVisibilityRelay
            .asDriver()
            .map { $0 == .visible ? Strings.hideQRCode : Strings.showQRCode }
            .drive(actionButtonModel.textRelay)
            .disposed(by: disposeBag)

        actionButtonModel
            .tapRelay
            .bind { [unowned self] in
                self.qrCodeVisibilityRelay.accept(self.qrCodeVisibilityRelay.value.inverted)
            }
            .disposed(by: disposeBag)
    }

}
