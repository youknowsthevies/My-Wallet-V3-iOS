//
//  CardDetailsScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 17/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import Localization
import ToolKit
import PlatformKit
import PlatformUIKit
import BuySellKit

final class CardDetailsScreenPresenter {
    
    // MARK: - Types
    
    enum PresentationError: Error {
        case generic
        case cardAlreadySaved
    }
    
    enum CellType {
        case textField(TextFieldType)
        case doubleTextField(TextFieldType, TextFieldType)
        case privacyNotice
                
        var row: Int {
            switch self {
            case .textField(.cardholderName):
                return 0
            case .textField(.cardNumber):
                return 1
            case .doubleTextField(.expirationDate, .cardCVV):
                return 2
            case .privacyNotice:
                return 3
            default:
                fatalError("No such cell type for cell type \(self)")
            }
        }
        
        init(_ row: Int) {
            switch row {
            case 0:
                self = .textField(.cardholderName)
            case 1:
                self = .textField(.cardNumber)
            case 2:
                self = .doubleTextField(.expirationDate, .cardCVV)
            case 3:
                self = .privacyNotice
            default:
                fatalError("No such cell type for row \(row)")
            }
        }
    }
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.CardDetailsScreen
    private typealias AccessibilityId = Accessibility.Identifier.CardDetailsScreen

    // MARK: - Exposed Properties
    
    var isValid: Driver<Bool> {
        isValidRelay.asDriver()
    }
    
    var error: Signal<PresentationError> {
        errorRelay.asSignal()
    }
    
    let title = LocalizedString.title
    
    let rowCount = 4
    let textFieldViewModelByType: [TextFieldType: TextFieldViewModel]
    let textFieldViewModels: [TextFieldViewModel]
    let noticeViewModel: NoticeViewModel
    let buttonViewModel: ButtonViewModel
    
    private let errorRelay = PublishRelay<PresentationError>()
    private let dataRelay = BehaviorRelay<CardData?>(value: nil)
    private let isValidRelay = BehaviorRelay(value: false)
    private let stateReducer = FormPresentationStateReducer()
    private let disposeBag = DisposeBag()

    private let interactor: CardDetailsScreenInteractor
    private let stateService: AddCardStateService
    private let eventRecorder: AnalyticsEventRecording
    private let cardNumberValidator: CardNumberValidator
    
    // MARK: - Setup
    
    init(stateService: AddCardStateService,
         interactor: CardDetailsScreenInteractor,
         eventRecorder: AnalyticsEventRecording,
         messageRecorder: MessageRecording) {
        self.interactor = interactor
        self.stateService = stateService
        self.eventRecorder = eventRecorder
        
        // Setup of the stored properties
        
        let cardCVVValidator = TextValidationFactory.Card.cvv
        cardNumberValidator = TextValidationFactory.Card.number
        
        let cvvToCardNumberMatcher = CVVToCreditCardMatchValidator(
            cvvTextSource: cardCVVValidator,
            cardTypeSource: cardNumberValidator,
            invalidReason: LocalizationConstants.TextField.Gesture.invalidCVV
        )
        
        let cardNumberTextFieldViewModel = CardTextFieldViewModel(
            validator: cardNumberValidator,
            messageRecorder: messageRecorder
        )
        let cardCVVTextFieldViewModel = CardCVVTextFieldViewModel(
            validator: cardCVVValidator,
            matchValidator: cvvToCardNumberMatcher,
            messageRecorder: messageRecorder
        )
        let cardExpiryTextFieldViewModel = CardExpiryTextFieldViewModel(
            messageRecorder: messageRecorder
        )
        let cardholderNameTextFieldViewModel = TextFieldViewModel(
            with: .cardholderName,
            returnKeyType: .next,
            validator: TextValidationFactory.Card.name,
            messageRecorder: messageRecorder
        )
        
        cardholderNameTextFieldViewModel.set(next: cardNumberTextFieldViewModel)
        cardNumberTextFieldViewModel.set(next: cardExpiryTextFieldViewModel)
        cardExpiryTextFieldViewModel.set(next: cardCVVTextFieldViewModel)

        textFieldViewModelByType = [
            .cardholderName: cardholderNameTextFieldViewModel,
            .expirationDate: cardExpiryTextFieldViewModel,
            .cardNumber: cardNumberTextFieldViewModel,
            .cardCVV: cardCVVTextFieldViewModel
        ]
        
        textFieldViewModels = [
            textFieldViewModelByType[.cardholderName]!,
            textFieldViewModelByType[.cardNumber]!,
            textFieldViewModelByType[.expirationDate]!,
            textFieldViewModelByType[.cardCVV]!
        ]
        
        buttonViewModel = .primary(with: LocalizedString.button)
        
        noticeViewModel = NoticeViewModel(
            imageViewContent: .init(
                imageName: "lock-icon",
                accessibility: .id(AccessibilityId.noticeImage),
                bundle: .platformUIKit
            ),
            labelContent: .init(
                text: LocalizedString.notice,
                font: .main(.medium, 12),
                color: .descriptionText,
                accessibility: .id(AccessibilityId.noticeLabel)
            ),
            verticalAlignment: .center
        )
        
        // Bind the stored properties
        
        let latestStatesObservable = Observable
            .combineLatest(
                cardholderNameTextFieldViewModel.state,
                cardNumberTextFieldViewModel.state,
                cardExpiryTextFieldViewModel.state,
                cardCVVTextFieldViewModel.state
            )
            .map { (name: $0.0, number: $0.1, expiry: $0.2, cvv: $0.3) }
            .share(replay: 1)
    
        latestStatesObservable
            .map(weak: stateReducer) { (reducer, states) in
                try reducer.reduce(
                    states: [states.name, states.number, states.expiry, states.cvv]
                )
            }
            .map { $0.isValid }
            .bind(to: isValidRelay)
            .disposed(by: disposeBag)
        
        latestStatesObservable
            .compactMap {
                CardData(
                    ownerName: $0.name.value,
                    number: $0.number.value,
                    expirationDate: $0.expiry.value,
                    cvv: $0.cvv.value
                )
            }
            .bind(to: dataRelay)
            .disposed(by: disposeBag)
        
        isValid
            .drive(buttonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        let buttonTapped = buttonViewModel.tapRelay
            .withLatestFrom(dataRelay)
            .compactMap { $0 }
            .flatMap(weak: self) { (self, cardData) in
                interactor
                    .doesCardExist(
                        number: cardData.number,
                        expiryMonth: cardData.month,
                        expiryYear: cardData.year
                    )
                    .map { (isExist: $0, data: cardData) }
                    .asObservable()
            }
            .mapToResult()
            .share(replay: 1)
        
        buttonTapped
            .filter { $0.isFailure }
            .mapToVoid()
            .map { .generic }
            .bind(to: errorRelay)
            .disposed(by: disposeBag)
        
        buttonTapped
            .compactMap { $0.successData }
            .bind(weak: self) { (self, payload) in
                if payload.isExist {
                    self.errorRelay.accept(.cardAlreadySaved)
                } else {
                    self.eventRecorder.record(event: AnalyticsEvent.sbCardInfoSet)
                    self.stateService.addBillingAddress(to: payload.data)
                }
            }
            .disposed(by: disposeBag)
        
        interactor.supportedCardTypes
            .subscribe(
                onSuccess: { [weak cardNumberValidator] cardTypes in
                    cardNumberValidator?.supportedCardTypesRelay.accept(cardTypes)
                },
                onError: { [weak errorRelay] _ in
                    errorRelay?.accept(.generic)
                }
            )
            .disposed(by: disposeBag)
    }
        
    func viewDidAppear() {
        eventRecorder.record(event: AnalyticsEvent.sbAddCardScreenShown)
    }
    
    // MARK: - Navigation
    
    func previous() {
        stateService.previousRelay.accept(())
    }
}
