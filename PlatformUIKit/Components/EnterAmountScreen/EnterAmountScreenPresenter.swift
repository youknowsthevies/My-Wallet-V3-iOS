//
//  EnterAmountScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RIBs
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

/// A presenter for enter amount screen. Designed to be subclassed by Buy, Sell, Send, Swap corresponding presenters
open class EnterAmountScreenPresenter: RibBridgePresenter {

    // MARK: - Types
    
    /// The state of the bottom auxiliary view
    public enum BottomAuxiliaryViewModelState {
        
        /// A selection button - used to show dropdowns
        case selection(SelectionButtonViewModel)
        
        /// Max available style button with available amount for spending and use-maximum button
        case maxAvailable(SendAuxililaryViewPresenter)
        
        /// Hidden - nothing to present
        case hidden
    }
    
    // MARK: - Properties

    public let deviceType = DevicePresenter.type
    let title: String

    public var bottomAuxiliaryViewModelState: Driver<BottomAuxiliaryViewModelState> {
        bottomAuxiliaryViewModelStateRelay.asDriver()
    }
    
    public let bottomAuxiliaryViewModelStateRelay = BehaviorRelay(
        value: BottomAuxiliaryViewModelState.hidden
    )
    
    public var continueButtonTapped: Signal<Void> {
        continueButtonViewModel.tap
    }
    
    // MARK: - Components (ViewModels / Presenters)
    
    public let topSelectionButtonViewModel: SelectionButtonViewModel
    
    let continueButtonViewModel: ButtonViewModel
    let amountTranslationPresenter: AmountTranslationPresenter
    let bottomAuxiliaryItemSeparatorViewModel: TitledSeparatorViewModel
    let digitPadViewModel: DigitPadViewModel

    // MARK: - Injected
    
    public let loader: LoadingViewPresenting
    public let alert: AlertViewPresenterAPI
    public let analyticsRecorder: AnalyticsEventRecorderAPI
    public let displayBundle: DisplayBundle

    private let interactor: EnterAmountScreenInteractor
    private let backwardsNavigation: () -> Void
    
    // MARK: - Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(loader: LoadingViewPresenting = resolve(),
                alert: AlertViewPresenterAPI = resolve(),
                analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
                backwardsNavigation: @escaping () -> Void,
                displayBundle: DisplayBundle,
                interactor: EnterAmountScreenInteractor) {
        self.loader = loader
        self.alert = alert
        self.analyticsRecorder = analyticsRecorder
        self.interactor = interactor
        self.backwardsNavigation = backwardsNavigation
        self.title = displayBundle.strings.title
        self.displayBundle = displayBundle
        bottomAuxiliaryItemSeparatorViewModel = TitledSeparatorViewModel(
            title: displayBundle.strings.bottomAuxiliaryItemSeparatorTitle,
            separatorColor: displayBundle.colors.bottomAuxiliaryItemSeparator,
            accessibilityId: displayBundle.accessibilityIdentifiers.bottomAuxiliaryItemSeparatorTitle
        )
        amountTranslationPresenter = AmountTranslationPresenter(
            interactor: interactor.amountTranslationInteractor,
            analyticsRecorder: analyticsRecorder,
            minTappedAnalyticsEvent: displayBundle.events.minTapped,
            maxTappedAnalyticsEvent: displayBundle.events.maxTapped
        )
        digitPadViewModel = EnterAmountScreenPresenter.digitPadViewModel()
        continueButtonViewModel = .primary(with: displayBundle.strings.ctaButton)
        topSelectionButtonViewModel = SelectionButtonViewModel(showSeparator: true)
        super.init(interactable: interactor)
    }
    
    // MARK: - Exposed methods
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide swap button
        amountTranslationPresenter.swapButtonVisibilityRelay.accept(.hidden)
        
        digitPadViewModel.valueObservable
            .filter { !$0.isEmpty }
            .map { Character($0) }
            .bindAndCatch(to: interactor.amountTranslationInteractor.appendNewRelay)
            .disposed(by: disposeBag)
                
        digitPadViewModel.backspaceButtonTapObservable
            .bindAndCatch(to: interactor.amountTranslationInteractor.deleteLastRelay)
            .disposed(by: disposeBag)

        interactor.hasValidState
            .bindAndCatch(to: continueButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        interactor.selectedCurrencyType
            .map {
                .image(
                    .init(
                        name: $0.logoImageName,
                        background: .clear,
                        offset: 0,
                        cornerRadius: .round,
                        size: .init(edge: 32)
                    )
                )
            }
            .bindAndCatch(to: topSelectionButtonViewModel.leadingContentTypeRelay)
            .disposed(by: disposeBag)

        interactor.selectedCurrencyType
            .map { $0.name }
            .bindAndCatch(to: topSelectionButtonViewModel.titleRelay)
            .disposed(by: disposeBag)

        interactor.selectedCurrencyType
            .map { .init(id: $0.displayCode, label: $0.name) }
            .bindAndCatch(to: topSelectionButtonViewModel.accessibilityContentRelay)
            .disposed(by: disposeBag)

        let displayBundle = self.displayBundle
        
        interactor.selectedCurrencyType
            .map { displayBundle.events.sourceAccountChanged($0.code) }
            .bindAndCatch(to: analyticsRecorder.recordRelay)
            .disposed(by: disposeBag)
    
        topSelectionButtonViewModel.trailingContentRelay.accept(
            .image(
                ImageViewContent(
                    imageName: "icon-disclosure-down-small"
                )
            )
        )
        
        interactor.didLoad()
    }
    
    open override func viewWillAppear() {
        super.viewWillAppear()
        analyticsRecorder.record(event: displayBundle.events.didAppear)
    }
        
    func previous() {
        backwardsNavigation()
    }
            
    public func handleError() {
        analyticsRecorder.record(event: displayBundle.events.confirmFailure)
        loader.hide()
        alert.error(in: nil, action: nil)
    }

    private static func digitPadViewModel() -> DigitPadViewModel {
        let highlightColor = Color.black.withAlphaComponent(0.08)
        let model = DigitPadButtonViewModel(
            content: .label(text: MoneyValueInputScanner.Constant.decimalSeparator, tint: .titleText),
            background: .init(highlightColor: highlightColor)
        )
        return DigitPadViewModel(
            padType: .number,
            customButtonViewModel: model,
            contentTint: .titleText,
            buttonHighlightColor: highlightColor
        )
    }
}
