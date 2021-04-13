//
//  BeneficiaryResponse.swift
//  BuySellKit
//
//  Created by Daniel on 14/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

struct BeneficiaryResponse: Decodable {
    
    struct Agent: Decodable {
        let account: String
    }
    
    let id: String
    let address: String
    let currency: String
    let name: String
    let agent: Agent
}
