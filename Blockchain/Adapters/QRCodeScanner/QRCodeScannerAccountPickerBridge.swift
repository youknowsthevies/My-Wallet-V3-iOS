//
//  QRCodeScannerAccountPickerBridge.swift
//  Blockchain
//

import Combine
import FeatureQRCodeScannerDomain
import Foundation
import PlatformKit
import PlatformUIKit
import RxSwift

/// Implements an AccountPickerAccountProviding & AccountPickerListener bridge for QRCodeScannerAdapter.
final class QRCodeScannerAccountPickerBridge {

    enum Event {
        case finished
        case didSelect(CryptoAccount, CryptoReceiveAddress)
    }

    var events: AnyPublisher<Event, Never> {
        eventsSubject.eraseToAnyPublisher()
    }

    var selectedTarget: AnyPublisher<QRCodeParserTarget, QRScannerError> {
        selectedTargetSubject.eraseToAnyPublisher()
    }

    let selectedTargetSubject = PassthroughSubject<QRCodeParserTarget, QRScannerError>()
    let selectableAccountsSubject = BehaviorSubject<[BlockchainAccount]>(value: [])

    private var targets: [QRCodeParserTarget] = []
    private let eventsSubject = PassthroughSubject<Event, Never>()

    init(targets: [QRCodeParserTarget]) {
        self.targets = targets
        selectableAccountsSubject.onNext(targets.compactMap(\.account))
    }
}

extension QRCodeScannerAccountPickerBridge: AccountPickerAccountProviding {
    var accounts: Observable<[BlockchainAccount]> {
        selectableAccountsSubject.asObservable()
    }
}

extension QRCodeScannerAccountPickerBridge: AccountPickerListener {
    func didSelect(blockchainAccount: BlockchainAccount) {
        guard let cryptoAccount = blockchainAccount as? CryptoAccount else {
            eventsSubject.send(.finished)
            return
        }
        let target = targets.firstNonNil { target -> CryptoReceiveAddress? in
            switch target {
            case .bitpay:
                return nil
            case .address(let account, let target):
                return account.identifier == cryptoAccount.identifier
                    ? target
                    : nil
            }
        }
        guard let target = target else {
            eventsSubject.send(.finished)
            return
        }
        eventsSubject.send(.didSelect(cryptoAccount, target))
    }

    func didSelectActionButton() {
        eventsSubject.send(.finished)
    }

    func didTapBack() {
        eventsSubject.send(.finished)
    }

    func didTapClose() {
        eventsSubject.send(.finished)
    }
}
