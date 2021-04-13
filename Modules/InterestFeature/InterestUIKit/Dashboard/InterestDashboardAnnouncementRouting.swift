//
//  InterestDashboardAnnouncementRouting.swift
//  InterestUIKit
//
//  Created by Alex McGregor on 8/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol InterestDashboardAnnouncementRouting {
    func dismiss(startKYC: Bool)
    func visitBlockchainTapped()
}
