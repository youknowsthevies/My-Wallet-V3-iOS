//
//  MainFlowProviding.swift
//  Blockchain
//
//  Created by Daniel Huri on 14/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

protocol MainFlowProviding: AnyObject {
    func setupMainFlow() -> Single<UIViewController>
}
