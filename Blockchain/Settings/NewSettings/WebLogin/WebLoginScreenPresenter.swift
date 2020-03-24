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
            .qrCode
            .map { QRCode(string: $0) }
            .map { $0?.image }
            .catchErrorJustReturn(nil)
    }

    var qrCodeVisibility: Driver<Visibility> {
        return qrCodeVisibilityRelay.asDriver()
    }

    let instructionViewModels: [InstructionCellViewModel] = {
        let inputs: [[InteractableTextViewModel.Input]] = [
            [.text(string: Strings.Instruction.one)],
            [.text(string: Strings.Instruction.two)],
            [.text(string: Strings.Instruction.three)]
        ]
        return inputs.enumerated().map {
            InstructionCellViewModel(number: $0.offset + 1, inputs: $0.element)
        }
    }()

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

        actionButtonModel
            .tapRelay
            .withLatestFrom(qrCodeVisibilityRelay)
            .map { $0.inverted }
            .bind(to: qrCodeVisibilityRelay)
            .disposed(by: disposeBag)
    }
}
