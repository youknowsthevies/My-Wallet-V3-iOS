//
//  BillingAddressScreenPresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 30/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import ToolKit
import PlatformKit
import PlatformUIKit

final class BillingAddressScreenPresenter {
        
    // MARK: - Types

    enum CellType: Equatable {
        case selectionView
        case textField(TextFieldType)
        case doubleTextField(TextFieldType, TextFieldType)
    }
    
    struct PresentationData {
        let cellTypes: [CellType]
        
        var cellCount: Int {
            return cellTypes.count
        }
        
        init(country: Country) {
            var cellTypes: [CellType] = [
                .selectionView,
                .textField(.personFullName),
                .textField(.addressLine(1)),
                .textField(.addressLine(2)),
                .textField(.city)
            ]
            switch country {
            case .US:
                cellTypes += [
                    .doubleTextField(.state, .postcode)
                ]
            default:
                cellTypes += [
                    .textField(.postcode)
                ]
            }
            self.cellTypes = cellTypes
        }
        
        func row(for cellType: CellType) -> Int {
            cellTypes.enumerated().first { $0.element == cellType }!.offset
        }
        
        func cellType(for row: Int) -> CellType {
            return cellTypes[row]
        }
    }
    
    private typealias LocalizedString = LocalizationConstants.BillingAddressScreen
    
    // MARK: - Properties
    
    let title = LocalizedString.title
    let buttonViewModel: ButtonViewModel
    
    let presentationDataRelay = BehaviorRelay(value: PresentationData(country: .US))

    let selectionButtonViewModel: SelectionButtonViewModel
    
    var refresh: Observable<Void> {
        refreshRelay.asObservable()
    }
    
    var isValid: Driver<Bool> {
        isValidRelay.asDriver()
    }

    var textFieldViewModelsMap: [TextFieldType: TextFieldViewModel] {
        textFieldViewModelsMapRelay.value
    }
    
    let textFieldViewModelsMapRelay = BehaviorRelay<[TextFieldType: TextFieldViewModel]>(value: [:])
    
    private let isValidRelay = BehaviorRelay(value: false)
    private let refreshRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()

    // MARK: - Injected
    
    private let interactor: BillingAddressScreenInteractor
    private let countrySelectionRouter: SelectionRouterAPI
    private let stateService: AddCardStateService
    private let loadingViewPresenter: LoadingViewPresenting

    init(interactor: BillingAddressScreenInteractor,
         countrySelectionRouter: SelectionRouterAPI,
         stateService: AddCardStateService,
         loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter.shared) {
        self.interactor = interactor
        self.stateService = stateService
        self.countrySelectionRouter = countrySelectionRouter
        self.loadingViewPresenter = loadingViewPresenter
        selectionButtonViewModel = SelectionButtonViewModel()
        buttonViewModel = .primary(with: LocalizedString.button)
        
        // 1. Country is selected
        // 2. `PresentationData` is regenerated
        // 3. Data is mapped into text field view models
        // 4. A layout refresh is triggered
        
        interactor.selectedCountry
            .map { .text($0.flag) }
            .bind(to: selectionButtonViewModel.leadingContentRelay)
            .disposed(by: disposeBag)

        interactor.selectedCountry
            .map { $0.name }
            .bind(to: selectionButtonViewModel.titleRelay)
            .disposed(by: disposeBag)

        interactor.selectedCountry
            .map { $0.code }
            .bind(to: selectionButtonViewModel.accessibilityLabelRelay)
            .disposed(by: disposeBag)
        
        interactor.selectedCountry
            .map { PresentationData(country: $0) }
            .bind(to: presentationDataRelay)
            .disposed(by: disposeBag)
        
        presentationDataRelay
            .map(weak: self) { (self, data) in
                self.transformPresentationDataIntoViewModels(data)
            }
            .bind(to: textFieldViewModelsMapRelay)
            .disposed(by: disposeBag)
        
        textFieldViewModelsMapRelay
            .mapToVoid()
            .bind(to: refreshRelay)
            .disposed(by: disposeBag)

        selectionButtonViewModel.tap
            .emit(onNext: { [unowned self] in
                self.showCountrySelectionScreen()
            })
            .disposed(by: disposeBag)
    
        let viewModelsObservable = textFieldViewModelsMapRelay
            .map { textFieldMap -> [TextFieldViewModel?] in
                [
                    textFieldMap[.personFullName],
                    textFieldMap[.addressLine(1)],
                    textFieldMap[.addressLine(2)],
                    textFieldMap[.city],
                    textFieldMap[.postcode],
                    textFieldMap[.state]
                ]
            }
            .map { viewModels in
                viewModels.compactMap { $0 }
            }
        
        let stateArrayObservable = viewModelsObservable
            .map { viewModels in
                viewModels.map { $0.state }
            }
            .flatMap { Observable.combineLatest($0) }
        
        let statesTuple = stateArrayObservable
            .map { states in
                return (
                    name: states[0],
                    addressLine1: states[1],
                    addressLine2: states[2],
                    city: states[3],
                    postcode: states[4],
                    state: states[safeIndex: 5]
                )
            }
        
        let billingAddress = Observable
            .combineLatest(
                statesTuple,
                interactor.selectedCountry
            )
            .map { payload -> BillingAddress? in
                let states = payload.0
                let country = payload.1
                return BillingAddress(
                    country: country,
                    fullName: states.name.value,
                    addressLine1: states.addressLine1.value,
                    addressLine2: states.addressLine2.value,
                    state: states.state?.value ?? "",
                    postCode: states.postcode.value
                )
            }
            .share(replay: 1)
                    
        billingAddress
            .compactMap { $0 }
            .bind(to: interactor.billingAddressRelay)
            .disposed(by: disposeBag)
        
        billingAddress
            .map { $0 != nil }
            .bind(to: isValidRelay)
            .disposed(by: disposeBag)
        
        isValid
            .drive(buttonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)
        
        buttonViewModel.tapRelay
            .withLatestFrom(interactor.billingAddress)
            .bind(weak: self) { (self, billingAddress) in
                self.add(billingAddress: billingAddress)
            }
            .disposed(by: disposeBag)
    }

    private func add(billingAddress: BillingAddress) {
        interactor
            .add(billingAddress: billingAddress)
            .handleLoaderForLifecycle(loader: loadingViewPresenter, style: .circle)
            .subscribe(
                onCompleted: { [weak stateService] in
                    stateService?.end()
                },
                onError: { error in
                    // TODO: IOS-3100 - Cards: Error handling
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func transformPresentationDataIntoViewModels(_ data: PresentationData) -> [TextFieldType: TextFieldViewModel] {
                
        func viewModel(by type: TextFieldType) -> TextFieldViewModel {
            TextFieldViewModel(
                with: type,
                hintDisplayType: .constant,
                validator: TextValidationFactory.General.notEmpty,
                messageRecorder: CrashlyticsRecorder()
            )
        }
        
        var viewModelByType: [TextFieldType: TextFieldViewModel] = [:]
        for cell in data.cellTypes {
            switch cell {
            case .doubleTextField(let leadingType, let trailingType):
                viewModelByType[leadingType] = viewModel(by: leadingType)
                viewModelByType[trailingType] = viewModel(by: trailingType)
            case .textField(let type):
                viewModelByType[type] = viewModel(by: type)
            case .selectionView:
                break
            }
        }
        return viewModelByType
    }
    
    private func showCountrySelectionScreen() {
        countrySelectionRouter.showSelectionScreen(
            screenTitle: LocalizationConstants.CountrySelectionScreen.title,
            searchBarPlaceholder: LocalizationConstants.CountrySelectionScreen.searchBarPlaceholder,
            using: interactor.countrySelectionService
        )
    }
}
