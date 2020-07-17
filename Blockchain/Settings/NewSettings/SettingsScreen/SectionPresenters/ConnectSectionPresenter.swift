//
//  ConnectSectionPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

final class ConnectSectionPresenter: SettingsSectionPresenting {
    
    typealias State = SettingsSectionLoadingState
    
    let sectionType: SettingsSectionType = .connect
    
    var state: Observable<State> {
        showConnectSection
            .map(weak: self) { (self, showConnect) -> State in
                guard showConnect else { return .loaded(next: .empty) }
                let presenter: PITConnectionCellPresenter = .init(
                    pitConnectionProvider: self.exchangeConnectionStatusProvider
                )
                return .loaded(next:
                    .some(
                        .init(
                            sectionType: self.sectionType,
                            items: [.init(cellType: .badge(.pitConnection, presenter))]
                        )
                    )
                )
        }
    }
    
    private var showConnectSection: Observable<Bool> {
        .just(configuration.isEnabled)
    }
    
    private let configuration: AppFeatureConfiguration
    private let exchangeConnectionStatusProvider: PITConnectionStatusProviding
    
    init(featureConfiguration: AppFeatureConfiguration,
         exchangeConnectionStatusProvider: PITConnectionStatusProviding) {
        self.configuration = featureConfiguration
        self.exchangeConnectionStatusProvider = exchangeConnectionStatusProvider
    }
}
