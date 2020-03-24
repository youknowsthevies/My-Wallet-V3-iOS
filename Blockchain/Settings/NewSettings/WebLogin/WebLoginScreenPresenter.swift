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

    private typealias AccessibilityIDs = Accessibility.Identifier.Settings.WebLogin
    private typealias LocalizedString = LocalizationConstants.Settings.WebLogin

    // MARK: - Public Properties

    let leadingButton: Screen.Style.LeadingButton = .back

    var titleView: Screen.Style.TitleView {
        .text(value: LocalizedString.title)
    }

    var barStyle: Screen.Style.Bar {
        .darkContent(ignoresStatusBar: false, background: .white)
    }

    var qrCodeImage: Single<UIImage?> {
        service
            .qrCode
            .map { QRCode(string: $0) }
            .map { $0?.image }
            .catchError { [weak self] error in
                guard let alertPresenter = self?.alertPresenter else { return .just(nil) }
                alertPresenter.notify(
                    content: .init(
                        title: LocalizedString.ErrorAlert.title,
                        message: LocalizedString.ErrorAlert.message
                    )
                )
                return .just(nil)
            }
    }

    var qrCodeVisibility: Driver<Visibility> {
        return qrCodeVisibilityRelay.asDriver()
    }

    let instructionViewModels: [InstructionCellViewModel] = {
        let inputs: [[InteractableTextViewModel.Input]] = [
            [.text(string: LocalizedString.Instruction.one)],
            [.text(string: LocalizedString.Instruction.two)],
            [.text(string: LocalizedString.Instruction.three)]
        ]
        return inputs.enumerated().map {
            InstructionCellViewModel(number: $0.offset + 1, inputs: $0.element)
        }
    }()

    let securityAlert: LabelContent
    let qrCodeSecurityAlertTop: LabelContent
    let qrCodeSecurityAlertBottom: LabelContent
    let actionButtonModel: ButtonViewModel

    // MARK: - Private Properties

    private let qrCodeVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let alertPresenter: AlertViewPresenter
    private let service: WebLoginQRCodeServiceAPI
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(alertPresenter: AlertViewPresenter = .shared,
         service: WebLoginQRCodeServiceAPI = WebLoginQRCodeService()) {
        self.alertPresenter = alertPresenter
        self.service = service
        securityAlert = .init(
            text: LocalizedString.securityMessageHidden,
            font: .mainMedium(14),
            color: .descriptionText,
            alignment: .center,
            accessibility: .id(AccessibilityIDs.securityAlertLabel)
        )
        qrCodeSecurityAlertTop = .init(
            text: LocalizedString.securityMessageVisible1,
            font: .mainMedium(14),
            color: .descriptionText,
            alignment: .center,
            accessibility: .id(AccessibilityIDs.securityAlertTopLabel)
        )
        qrCodeSecurityAlertBottom = .init(
            text: LocalizedString.securityMessageVisible2,
            font: .mainMedium(14),
            color: .descriptionText,
            alignment: .center,
            accessibility: .id(AccessibilityIDs.securityAlertBottomLabel)
        )

        actionButtonModel = .primary(with: LocalizedString.hideQRCode, accessibilityId: AccessibilityIDs.showQRCodeButton)

        qrCodeVisibilityRelay
            .asDriver()
            .map { $0 == .visible ? LocalizedString.hideQRCode : LocalizedString.showQRCode }
            .drive(actionButtonModel.textRelay)
            .disposed(by: disposeBag)

        actionButtonModel
            .tapRelay
            .withLatestFrom(qrCodeVisibilityRelay)
            .map { $0.inverted }
            .bind(to: qrCodeVisibilityRelay)
            .disposed(by: disposeBag)
    }
}
