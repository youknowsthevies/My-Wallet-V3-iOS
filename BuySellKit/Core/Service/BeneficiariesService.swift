//
//  BeneficiariesService.swift
//  BuySellKit
//
//  Created by Daniel on 14/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxRelay
import ToolKit

public protocol BeneficiariesServiceAPI: AnyObject {
    var beneficiaries: Single<[Beneficiary]> { get }
    var hasLinkedBank: Single<Bool> { get }
    func fetch() -> Single<[Beneficiary]>
}

final class BeneficiariesService: BeneficiariesServiceAPI {

    // MARK: - Properties
    
    var beneficiaries: Single<[Beneficiary]> {
        _ = setup
        return cachedValue.valueSingle
    }
    
    var hasLinkedBank: Single<Bool> {
        beneficiaries.map { !$0.isEmpty }
    }
    
    private lazy var setup: Void = {
        cachedValue.setFetch(weak: self) { (self) in
            self.client.beneficiaries
                .map { $0.compactMap { Beneficiary(response: $0) } }
        }
    }()
    
    private let client: BeneficiariesClientAPI
    private let cachedValue: CachedValue<[Beneficiary]>
    
    // MARK: - Setup
    
    init(client: BeneficiariesClientAPI) {
        self.client = client
        cachedValue = CachedValue(configuration: .onSubscription())
    }
    
    func fetch() -> Single<[Beneficiary]> {
        _ = setup
        return cachedValue.fetchValue
    }
}
