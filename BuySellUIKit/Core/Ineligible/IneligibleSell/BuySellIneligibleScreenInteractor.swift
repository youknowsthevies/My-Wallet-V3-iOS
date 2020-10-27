//
//  BuySellIneligibleScreenInteractor.swift
//  BuySellUIKit
//
//  Created by Alex McGregor on 9/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift

public final class BuySellIneligibleScreenInteractor {
    
    // MARK: - Public
    
    var region: Single<String> {
        dataRepositoryAPI
        .userSingle
            .map { $0.address?.state ?? (Country.current ?? .US).name }
    }
    
    // MARK: - Injected
    
    private let dataRepositoryAPI: DataRepositoryAPI
    
    // MARK: - Init
    
    init(dataRepositoryAPI: DataRepositoryAPI = resolve()) {
        self.dataRepositoryAPI = dataRepositoryAPI
    }
    
}
