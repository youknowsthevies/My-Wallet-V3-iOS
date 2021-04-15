//
//  ReceiveScreenPresenter.swift
//  TransactionUIKit
//
//  Created by Paulo on 21/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class ReceiveScreenPresenter {

    // MARK: Types

    private typealias LocalizedString = LocalizationConstants.Receive
    private typealias AccessibilityID = Accessibility.Identifier.Receive

    // MARK: Properties

    let nameLabelContentPresenting: LabelContentPresenting
    let balanceLabelContentPresenting: LabelContentPresenting
    let addressLabelContentPresenting: LabelContentPresenting
    let walletAddressLabelContent: LabelContent
    let copyButton: ButtonViewModel
    let shareButton: ButtonViewModel
    private (set) lazy var title = "\(LocalizedString.Text.receive) \(interactor.account.currencyType.code)"
    var assetImage: Driver<UIImage?> {
        let imageName = interactor.account
            .currencyType
            .logoImageName
        let image = UIImage(named: imageName)
        return .just(image)
    }
    var qrCode: Driver<UIImage?> {
        qrCodeRelay.asDriver()
    }

    // MARK: Private Properties

    private let qrCodeRelay = BehaviorRelay<UIImage?>(value: nil)
    private let interactor: ReceiveScreenInteractor
    private let disposeBag = DisposeBag()

    // MARK: Setup

    init(pasteboard: Pasteboarding = resolve(),
         interactor: ReceiveScreenInteractor) {
        self.interactor = interactor
        walletAddressLabelContent = LabelContent(
            text: LocalizedString.Text.walletAddress,
            font: .main(.semibold, 12),
            color: .titleText
        )
        nameLabelContentPresenting = DefaultLabelContentPresenter(
            knownValue: interactor.account.label,
            descriptors: .init(
                fontWeight: .semibold,
                contentColor: .textFieldText,
                fontSize: 16,
                accessibilityId: AccessibilityID.walletNameLabel
            )
        )
        balanceLabelContentPresenting = DefaultLabelContentPresenter(
            knownValue: "  ",
            descriptors:  .init(
                fontWeight: .medium,
                contentColor: .descriptionText,
                fontSize: 14,
                accessibilityId: AccessibilityID.balanceLabel
            )
        )
        addressLabelContentPresenting = DefaultLabelContentPresenter(
            knownValue: "  ",
            descriptors: .init(
                fontWeight: .medium,
                contentColor: .darkTitleText,
                fontSize: 14,
                accessibilityId: AccessibilityID.addressLabel
            )
        )
        copyButton = .secondary(with: LocalizedString.Button.copy)
        shareButton = .primary(with: LocalizedString.Button.share)

        let qrCodeMetadata = interactor.qrCodeMetadata
            .asObservable()
            .share(replay: 1)

        let address = qrCodeMetadata
            .map(\.address)
            .share(replay: 1)

        qrCodeMetadata
            .map { metadata -> QRCodeAPI? in
                QRCode(metadata: metadata)
            }
            .map { $0?.image }
            .catchErrorJustReturn(nil)
            .bindAndCatch(to: qrCodeRelay)
            .disposed(by: disposeBag)

        address
            .map { LabelContent.Value.Interaction.Content(text: $0) }
            .map { .loaded(next: $0) }
            .bindAndCatch(to: addressLabelContentPresenting.interactor.stateRelay)
            .disposed(by: disposeBag)

        interactor.account
            .balance
            .map { $0.toDisplayString(includeSymbol: true) }
            .asObservable()
            .mapToLabelContentStateInteraction()
            .catchErrorJustReturn(.loading)
            .bindAndCatch(to: balanceLabelContentPresenting.interactor.stateRelay)
            .disposed(by: disposeBag)

        // MARK: - Copy

        copyButton.tapRelay
            .withLatestFrom(address)
            .bind { pasteboard.string = $0 }
            .disposed(by: disposeBag)

        copyButton.tapRelay
            .bindAndCatch(weak: self) { (self, theme) in
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred()
            }
            .disposed(by: disposeBag)
        
        copyButton.tapRelay
            .map {
                ButtonViewModel.Theme(
                    backgroundColor: .successButton,
                    contentColor: .white,
                    text: LocalizedString.Button.copied
                )
            }
            .bindAndCatch(weak: self) { (self, theme) in
                self.copyButton.animate(theme: theme)
            }
            .disposed(by: disposeBag)

        copyButton.tapRelay
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                self.copyButton.animate(theme: ButtonViewModel.secondary(with: LocalizedString.Button.copy).theme)
            }
            .disposed(by: disposeBag)

        // MARK: - Share

        shareButton.tapRelay
            .withLatestFrom(qrCodeMetadata)
            .subscribe(onNext: { [weak self] metadata in
                guard let self = self else { return }
                self.interactor.receiveRouter.shareDetails(for: metadata)
            })
            .disposed(by: disposeBag)
    }
}
