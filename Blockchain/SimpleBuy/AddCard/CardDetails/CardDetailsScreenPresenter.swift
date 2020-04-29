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
import ToolKit
import PlatformKit
import PlatformUIKit

final class CardDetailsScreenPresenter {
    
    // MARK: - Types
    
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
    
    let title = LocalizedString.title
    
    let textFieldViewModelByType: [TextFieldType: TextFieldViewModel]
    let textFieldViewModels: [TextFieldViewModel]
    let noticeViewModel: NoticeViewModel
    let buttonViewModel: ButtonViewModel
    
    private let dataRelay = BehaviorRelay<CardData?>(value: nil)
    private let isValidRelay = BehaviorRelay(value: false)
    private let stateReducer = FormPresentationStateReducer()
    private let disposeBag = DisposeBag()

    private let stateService: AddCardStateService
    private let eventRecorder: AnalyticsEventRecording
    
    // MARK: - Setup
    
    init(stateService: AddCardStateService,
         eventRecorder: AnalyticsEventRecording = AnalyticsEventRecorder.shared) {
        self.stateService = stateService
        self.eventRecorder = eventRecorder
        
        // Setup of the stored properties
        
        let cardCVVValidator = TextValidationFactory.Card.cvv
        let cardNumberValidator = TextValidationFactory.Card.number
        
        let cvvToCardNumberMatcher = CVVToCreditCardMatchValidator(
            cvvTextSource: cardCVVValidator,
            cardTypeSource: cardNumberValidator,
            invalidReason: LocalizationConstants.TextField.Gesture.invalidCVV
        )
        
        let cardNumberTextFieldViewModel = CardTextFieldViewModel(
            validator: cardNumberValidator,
            messageRecorder: CrashlyticsRecorder()
        )
        let cardCVVTextFieldViewModel = CardCVVTextFieldViewModel(
            validator: cardCVVValidator,
            matchValidator: cvvToCardNumberMatcher,
            messageRecorder: CrashlyticsRecorder()
        )
        let cardExpiryTextFieldViewModel = CardExpiryTextFieldViewModel(
            messageRecorder: CrashlyticsRecorder()
        )
        let cardholderNameTextFieldViewModel = TextFieldViewModel(
            with: .cardholderName,
            hintDisplayType: .constant,
            validator: TextValidationFactory.Card.name,
            messageRecorder: CrashlyticsRecorder()
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
                font: .mainMedium(12),
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
        
        buttonViewModel.tapRelay
            .withLatestFrom(dataRelay)
            .compactMap { $0 }
            .bind(weak: self) { (self, cardData) in
                self.eventRecorder.record(event: AnalyticsEvent.sbCardInfoSet)
                self.stateService.addBillingAddress(to: cardData)
            }
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
