//
//  BillingAddressScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import PlatformUIKit
import BuySellKit

final class BillingAddressScreenInteractor {
    
    // MARK: - Properties
    
    var selectedCountry: Observable<Country> {
        countrySelectionService.selectedData
            .map { $0.id }
            .compactMap { Country(code: $0) }
    }
        
    // MARK: - Setup
    
    let countrySelectionService: CountrySelectionService
    
    var billingAddress: Observable<BillingAddress> {
        billingAddressRelay
            .compactMap { $0 }
    }
    
    let billingAddressRelay = BehaviorRelay<BillingAddress?>(value: nil)
    
    private let service: CardUpdateServiceAPI
    private let cardData: CardData    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(cardData: CardData,
         service: CardUpdateServiceAPI,
         userDataRepository: DataRepositoryAPI) {
        self.cardData = cardData
        self.service = service
        countrySelectionService = CountrySelectionService(defaultSelectedData: Country.current ?? .US)
        
        userDataRepository.userSingle
            .map { $0.address }
            .subscribe(
                onSuccess: { [weak self] address in
                    guard let address = address else { return }
                    self?.set(userAddress: address)
                }
            )
            .disposed(by: disposeBag)
    }
    
    func add(billingAddress: BillingAddress) -> Single<PartnerAuthorizationData> {
        let cardData = self.cardData.data(byAppending: billingAddress)
        return service.add(card: cardData)
    }
    
    private func set(userAddress: UserAddress) {
        countrySelectionService.set(country: userAddress.country)
    }
}
