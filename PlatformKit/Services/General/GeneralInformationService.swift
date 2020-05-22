//
//  GeneralInformationService.swift
//  Blockchain
//
//  Created by Daniel Huri on 15/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public final class GeneralInformationService {
    
    // MARK: - Exposed
    
    /// Provides the countries fetched from remote
    public var countries: Single<[CountryData]> {
        countriesCachedValue.valueSingle
    }
    
    private let client: GeneralInformationClientAPI
    private let countriesCachedValue: CachedValue<[CountryData]>
    
    public init(client: GeneralInformationClientAPI = GeneralInformationClient()) {
        self.client = client
        
        countriesCachedValue = .init(
            configuration: .init(
                identifier: "fetch-countries",
                refreshType: .periodic(seconds: 60 * 60)
            )
        )
        
        countriesCachedValue
            .setFetch(weak: self) { (self) in
                self.client.countries
                    .map {
                        $0.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
                    }
            }
    }
}
