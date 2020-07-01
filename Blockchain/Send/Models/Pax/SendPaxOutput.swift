//
//  SendPaxOutput.swift
//  Blockchain
//
//  Created by AlexM on 5/30/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ERC20Kit
import EthereumKit
import Foundation
import PlatformKit

struct SendPaxOutput {
    var presentationUpdates: Set<SendMoniesPresentationUpdate>
    var model: SendPaxViewModel
}
