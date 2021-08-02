// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxCocoa
import RxSwift

/// A presenter for pairing intro screen
struct PairingIntroScreenPresenter {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.Onboarding.PairingIntroScreen

    // MARK: - Properties

    let navBarStyle = Screen.Style.Bar.lightContent()
    let titleStyle = Screen.Style.TitleView.text(value: LocalizedString.title)
    let instructionViewModels: [InstructionCellViewModel] = {
        let inputs: [[InteractableTextViewModel.Input]] = [
            [
                .text(string: LocalizedString.Instruction.firstPrefix),
                .url(string: LocalizedString.Instruction.firstSuffix, url: Constants.Url.blockchainWalletLogin)
            ],
            [.text(string: LocalizedString.Instruction.second)],
            [.text(string: LocalizedString.Instruction.third)]
        ]
        return inputs.enumerated().map {
            InstructionCellViewModel(number: $0.offset + 1, inputs: $0.element)
        }
    }()

    let primaryButtonViewModel = ButtonViewModel.primary(
        with: LocalizedString.primaryButton
    )
    let secondaryButtonViewModel = ButtonViewModel.secondary(
        with: LocalizedString.secondaryButton
    )

    /// Should connect to manual pairing flow
    let manualPairingNavigationRelay = PublishRelay<Void>()

    /// Should connect to auto pairing flow
    let autoPairingNavigationRelay = PublishRelay<Void>()

    // MARK: - Accessors

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init() {
        primaryButtonViewModel.tapRelay
            .bindAndCatch(to: autoPairingNavigationRelay)
            .disposed(by: disposeBag)
        secondaryButtonViewModel.tapRelay
            .bindAndCatch(to: manualPairingNavigationRelay)
            .disposed(by: disposeBag)
    }
}
