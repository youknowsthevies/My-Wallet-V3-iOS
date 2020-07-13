//
//  TetherServiceProvider.swift
//  Blockchain
//
//  Created by Paulo on 01/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class TetherServiceProvider {

    static let shared: TetherServiceProvider = TetherServiceProvider(services: TetherServices())

    let services: TetherDependencies

    init(services: TetherDependencies) {
        self.services = services
    }
}
