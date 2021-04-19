//
//  QRCodeScannerOverlayViewModel.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 2/9/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift

final class QRCodeScannerOverlayViewModel {
    
    /// The visibility of the camera roll button
    var cameraRollButtonVisibility: Driver<Visibility> {
        cameraRollButtonVisibilityRelay
            .asDriver(onErrorJustReturn: .hidden)
    }
    
    /// Is the flash enabled
    var flashEnabled: Driver<Bool> {
        qrCodeFlashService.isEnabled
    }

    /// Streams events when a scan was successful 
    let scanSuccess = PublishRelay<Bool>()
    
    /// Streams events when the flash button is tapped
    let flashTapRelay = PublishRelay<Void>()
    
    /// Streams events when the camera button is tapped
    let cameraTapRelay = PublishRelay<Void>()
    
    /// Closure for handling camera tap events
    var cameraButtonTapped: (() -> Void)?
    
    private let qrCodeFlashService = QRCodeScannerFlashService()
    private let cameraRollButtonVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let disposeBag = DisposeBag()
    
    init(supportsCameraRoll: Bool) {
        cameraRollButtonVisibilityRelay.accept(supportsCameraRoll ? .visible : .hidden)
        flashTapRelay
            .bindAndCatch(weak: self) { (self) in
                self.toggleFlash()
            }
            .disposed(by: disposeBag)
        
        cameraTapRelay
            .bindAndCatch(weak: self) { (self) in
                self.cameraButtonTapped?()
            }
            .disposed(by: disposeBag)
    }
    
    private func toggleFlash() {
        qrCodeFlashService.toggleFlash()
    }
}
