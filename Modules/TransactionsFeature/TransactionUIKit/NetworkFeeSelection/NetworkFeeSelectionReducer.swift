//
//  NetworkFeeSelectionReducer.swift
//  TransactionUIKit
//
//  Created by Alex McGregor on 3/24/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformUIKit
import RxCocoa
import TransactionKit

protocol NetworkFeeSelectionReducerAPI {
    func presentableState(for interactorState: Driver<NetworkFeeSelectionInteractor.State>) -> Driver<NetworkFeeSelectionPresenter.State>
}

final class NetworkFeeSelectionReducer: NetworkFeeSelectionReducerAPI {
    
    private typealias LocalizationId = LocalizationConstants.Transaction.Send
    private typealias PresenterState = NetworkFeeSelectionPresenter.State
    
    func presentableState(for interactorState: Driver<NetworkFeeSelectionInteractor.State>) -> Driver<NetworkFeeSelectionPresenter.State> {
        
        let title: LabelContent = .init(
            text: LocalizationId.networkFee,
            font: .main(.semibold, 16),
            color: .textFieldText,
            alignment: .left,
            accessibility: .none
        )
        let regular = interactorState
            .map(\.selectedFeeLevel)
            .map {
                RadioLineItemCellPresenter(
                    title: FeeLevel.regular.title,
                    subtitle: "\(60)+ \(LocalizationId.min)",
                    selected: $0 == .regular
                )
            }
        let isOkEnabled = interactorState
            .map(\.okButtonEnabled)
            .asDriver()
        let priority = interactorState
            .map(\.selectedFeeLevel)
            .map {
                RadioLineItemCellPresenter(
                    title: FeeLevel.priority.title,
                    subtitle: "\(30) \(LocalizationId.minutes)",
                    selected: $0 == .priority
                )
            }
        
        return Driver.zip(regular, priority)
            .map { (regular, priority) in
                PresenterState(
                    title: title,
                    isOkEnabled: isOkEnabled,
                    regular: regular,
                    priority: priority
                )
            }
    }
}
