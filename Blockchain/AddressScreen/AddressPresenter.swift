// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformUIKit
import RxCocoa
import RxSwift

// The presenter of the address screen
final class AddressPresenter {

    /// The name of the asset
    let assetName: String

    /// The asset name label accessibility
    var titleAccessibility: Accessibility {
        Accessibility(id: AccessibilityIdentifiers.Address.assetNameLabel,
                      traits: .header)
    }

    /// Relay that accepts and streams the address status
    private let statusRelay = BehaviorRelay<DisplayAddressStatus>(value: .awaitingFetch)

    /// The status of the address. Streams values on the `MainScheduler` by default
    var status: Observable<DisplayAddressStatus> {
        statusRelay
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
    }

    /// View model for the copy button view
    let copyViewModel = ButtonViewModel(
        font: Font(.branded(.montserratRegular), size: .custom(20)).result,
        accessibility: Accessibility(
            id: AccessibilityIdentifiers.Address.copyButton,
            label: LocalizationConstants.Address.Accessibility.copyButton,
            traits: .button
        )
    )

    /// View model for the share button view
    let shareViewModel = ButtonViewModel(
        font: Font(.branded(.montserratRegular), size: .custom(20)).result,
        accessibility: Accessibility(
            id: AccessibilityIdentifiers.Address.shareButton,
            label: LocalizationConstants.Address.Accessibility.shareButton,
            traits: .button
        )
    )

    /// View model for the QR address view
    let qrAddressViewModel = QRAddressViewModel()

    /// Computed variable that returns the asset image.
    var assetImage: UIImage {
        interactor.asset.logo
    }

    /// Accepts and streams the raw address in order to share it
    private let addressShareRelay = PublishRelay<WalletAddressContent>()

    /// Observes the address for sharing purpose
    var addressShare: Observable<String> {
        addressShareRelay
            .map { $0.string }
            .observeOn(MainScheduler.instance)
            .asObservable()
    }

    // MARK: - Services

    private let interactor: AddressInteracting
    private let pasteboard: Pasteboarding

    // MARK: - Rx

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(interactor: AddressInteracting,
         pasteboard: Pasteboarding = resolve()) {
        self.interactor = interactor
        self.pasteboard = pasteboard
        let asset = interactor.asset
        assetName = String(format: LocalizationConstants.Address.titleFormat, asset.name)

        setupCopyViewModel()
        setupShareViewModel()

        // Streams the status to the qr address view model
        status
            .bindAndCatch(to: qrAddressViewModel.statusRelay)
            .disposed(by: disposeBag)

        status
            .map { $0.isReady }
            .bindAndCatch(to: copyViewModel.isEnabledRelay,
                      shareViewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        // Streams taps the address upon tapping copy button
        let copyTap = copyViewModel.tapRelay
            .withLatestFrom(status)
            .filter { $0.isReady }
            .map { $0.addressContent! }

        // The user is allowed tap either the QR address view or the copy button itself
        for copy in [qrAddressViewModel.copy, copyTap] {

            // Copy address and adjust view model's state
            copy
                .bind { [unowned self] content in
                    self.copy(addressContent: content)
                }
                .disposed(by: disposeBag)

            // Delay by Xs before switching its view model's state back
            copy
                .delay(.seconds(3), scheduler: MainScheduler.instance)
                .bind { [weak self] _ in
                    self?.setupCopyViewModel()
                }
                .disposed(by: disposeBag)
        }

        // Bind taps on share button
        shareViewModel.tapRelay
            .withLatestFrom(status)
            .filter { $0.isReady }
            .map { $0.addressContent! }
            .bindAndCatch(to: addressShareRelay)
            .disposed(by: disposeBag)

        // Bind any received payment to `statusRelay`
        interactor.receivedPayment
            .map { _ -> DisplayAddressStatus in
                .awaitingFetch
            }
            .asDriver(onErrorJustReturn: .awaitingFetch)
            .drive(statusRelay)
            .disposed(by: disposeBag)
    }

    /// Fetches new address and streams it using `status`.
    /// This method makes `status` to stream a valid value.
    func fetchAddress() {

        // Update the status
        statusRelay.accept(.fetching)

        // Get the next address
        interactor.address
            .map { content -> DisplayAddressStatus in
                .readyForDisplay(content: content)
            }
            .catchError { error -> Single<DisplayAddressStatus> in
                switch error {
                case AddressFetchingError.unretainedSelf:
                    throw error
                case AddressFetchingError.absent:
                    return .just(.fetchFailure(localizedReason: LocalizationConstants.Address.loginToRefreshAddress))
                default:
                    return .just(.awaitingFetch)
                }
            }
            .subscribe(onSuccess: { [weak self] status in
                self?.statusRelay.accept(status)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Accessors

    private func copy(addressContent: WalletAddressContent) {

        // Copy the address
        pasteboard.string = addressContent.string

        // Set copy view model
        setCopyViewModelToCopiedState()

        // Make an impact feedback
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }

    private func setupShareViewModel() {
        let theme = ButtonViewModel.Theme(backgroundColor: .secondary,
                                                   contentColor: .white,
                                                   imageName: "share_icon",
                                                   text: LocalizationConstants.Address.shareButton)
        shareViewModel.animate(theme: theme)
    }

    private func setCopyViewModelToCopiedState() {
        let theme = ButtonViewModel.Theme(backgroundColor: .successButton,
                                                   contentColor: .white,
                                                   text: LocalizationConstants.Address.copiedButton)
        copyViewModel.animate(theme: theme)
    }

    private func setupCopyViewModel() {
        let theme = ButtonViewModel.Theme(backgroundColor: .secondary,
                                                    contentColor: .white,
                                                    imageName: "copy_icon",
                                                    text: LocalizationConstants.Address.copyButton)
        copyViewModel.animate(theme: theme)
    }
}
