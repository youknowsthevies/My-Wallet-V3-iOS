//
//  SettingsSectionPresenting.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

protocol SettingsSectionPresenting: class {
    var sectionType: SettingsSectionType { get }
    var state: Observable<SettingsSectionLoadingState> { get }
}
