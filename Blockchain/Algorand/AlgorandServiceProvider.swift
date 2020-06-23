//
//  AlgorandServiceProvider.swift
//  Blockchain
//
//  Created by Paulo on 10/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

final class AlgorandServiceProvider {

    static let shared: AlgorandServiceProvider = AlgorandServiceProvider(services: AlgorandServices())

    let services: AlgorandDependencies

    init(services: AlgorandServices) {
        self.services = services
    }
}
