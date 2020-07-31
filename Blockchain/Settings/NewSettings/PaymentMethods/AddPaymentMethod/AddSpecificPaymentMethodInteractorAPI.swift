//
//  AddSpecificPaymentMethodInteractorAPI.swift
//  Blockchain
//
//  Created by Daniel on 22/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

protocol AddSpecificPaymentMethodInteractorAPI: AnyObject {
    var isAbleToAddNew: Observable<Bool> { get }
}
