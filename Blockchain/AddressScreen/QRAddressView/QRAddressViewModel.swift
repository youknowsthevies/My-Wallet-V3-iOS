// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxCocoa
import RxSwift

final class QRAddressViewModel {
    
    // MARK: - Properties
    
    /// The status relay - accepts and streams
    let statusRelay = BehaviorRelay<DisplayAddressStatus>(value: .awaitingFetch)
    
    /// The status observable - streams events
    var status: Observable<DisplayAddressStatus> {
        statusRelay.asObservable()
    }
    
    /// Accepts tap from the view
    let tapRelay = PublishRelay<Void>()
    
    /// Streams taps foreward
    let copy: Observable<WalletAddressContent>
    
    private let disposeBag = DisposeBag()
    
    // Address label accessibility
    var addressLabelAccessibility: Accessibility {
        Accessibility(id: .value(AccessibilityIdentifiers.Address.addressLabel),
                             hint: .value(LocalizationConstants.Address.Accessibility.addressLabel))
    }
    
    // Address QR image view accessibility
    var addressImageViewAccessibility: Accessibility {
        Accessibility(id: .value(AccessibilityIdentifiers.Address.qrImageView),
                             hint: .value(LocalizationConstants.Address.Accessibility.addressImageView))
    }
    
    // Copy button accessibility
    var copyButtonAcessibility: Accessibility {
        Accessibility(id: .value(AccessibilityIdentifiers.Address.copyButton),
                             hint: .value(LocalizationConstants.Address.Accessibility.copyButton))
    }
    
    // MARK: - Setup
    
    init() {
        copy = tapRelay
            .withLatestFrom(statusRelay)
            .filter { $0.isReady }
            .map { $0.addressContent! }
    }
}
