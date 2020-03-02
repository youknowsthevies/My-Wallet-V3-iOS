//
//  SelectionServiceAPI.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 31/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

public protocol SelectionServiceAPI: class {
    
    var dataSource: Observable<[SelectionItemViewModel]> { get }
    var selectedDataRelay: BehaviorRelay<SelectionItemViewModel> { get }
    var selectedData: Observable<SelectionItemViewModel> { get }
}
