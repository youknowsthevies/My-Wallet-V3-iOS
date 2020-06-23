//
//  SendContainerViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

// TODO: Temporary workaround - refactor
final class SendContainerViewController: UIViewController {
    
    private lazy var sendRouter: SendRouter = {
        return SendRouter(using: self)
    }()
    
    private lazy var bitcoinVC: SendBitcoinViewController = {
        return SendBitcoinViewController(nibName: "SendCoins", bundle: nil)
    }()
    
    private lazy var stellarVC = SendLumensViewController.make(with: .shared)
    private lazy var paxVC = SendPaxViewController.make()
    
    private weak var currentVC: UIViewController!
    
    func set(asset: CryptoCurrency) {
        currentVC?.remove()
        switch asset {
        case .algorand:
            fatalError("Algorand not supported")
        case .bitcoin:
            currentVC = bitcoinVC
            bitcoinVC.assetType = .bitcoin
        case .bitcoinCash:
            currentVC = bitcoinVC
            bitcoinVC.assetType = .bitcoinCash
        case .stellar:
            currentVC = stellarVC
        case .ethereum:
            currentVC = sendRouter.sendViewController(by: .ether)
        case .pax:
            currentVC = paxVC
        }
        add(child: currentVC)
    }
}
