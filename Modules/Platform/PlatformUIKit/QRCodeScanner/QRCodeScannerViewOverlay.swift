//
//  QRCodeScannerViewOverlay.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 2/8/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

final class QRCodeScannerViewOverlay: UIView {
    
    /// The area that the QR code must be within.
    var scannableFrame: CGRect {
        CGRect(
            origin: center,
            size: .edge(280)
        )
        .offsetBy(
            dx: -(280 / 2),
            dy: -(280 / 2)
        )
    }
    
    private let viewModel: QRCodeScannerOverlayViewModel
    private let scanningViewFinder = UIView()
    private let flashButton = UIButton()
    private let cameraRollButton = UIButton()
    private let disposeBag = DisposeBag()
    private let scanningBorder = CAShapeLayer()
    
    init(viewModel: QRCodeScannerOverlayViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(frame: frame)
        setupSubviews()

        viewModel.scanSuccess
            .subscribe(onNext: { [weak self] isSuccess in
                self?.setScanningBorder(color: isSuccess ? .green500 : .white)
            })
            .disposed(by: disposeBag)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setScanningBorder(color: UIColor) {
        UIView.animate(withDuration: 0.3) {
            self.scanningBorder.strokeColor = color.cgColor
        }
    }
    
    private func setupSubviews() {
        backgroundColor = UIColor.primary.withAlphaComponent(0.9)
        setupButtons()
        setupScanningView()
    }
    
    private func setupButtons() {
        addSubview(flashButton)
        addSubview(cameraRollButton)
        cameraRollButton.layout(size: .edge(44))
        cameraRollButton.layoutToSuperview(.trailing, offset: -44)
        cameraRollButton.layoutToSuperview(.bottom, offset: -64)
        
        flashButton.layout(size: .edge(44))
        flashButton.layoutToSuperview(.leading, offset: 44)
        flashButton.layoutToSuperview(.bottom, offset: -64)
        
        viewModel
            .cameraRollButtonVisibility
            .map(\.isHidden)
            .drive(cameraRollButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        cameraRollButton.rx.tap
            .throttle(
                .milliseconds(200),
                latest: false,
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .observeOn(MainScheduler.instance)
            .bindAndCatch(to: viewModel.cameraTapRelay)
            .disposed(by: disposeBag)
        
        viewModel
            .flashEnabled
            .drive(flashButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        flashButton.rx.tap
            .throttle(
                .milliseconds(200),
                latest: false,
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .observeOn(MainScheduler.instance)
            .bindAndCatch(to: viewModel.flashTapRelay)
            .disposed(by: disposeBag)
        
        cameraRollButton.setImage(UIImage(named: "camera-roll-button"), for: .normal)
        
        flashButton.setImage(UIImage(named: "flash-button"), for: .normal)
        flashButton.setImage(UIImage(named: "flash-enabled-button"), for: .selected)
        flashButton.setImage(UIImage(named: "flash-enabled-button"), for: .highlighted)
    }
    
    private func setupScanningView() {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        let path = UIBezierPath(rect: bounds)
        path.append(
            .init(roundedRect: scannableFrame,
                  byRoundingCorners: .allCorners,
                  cornerRadii: .edge(8)
            )
        )
        maskLayer.fillRule = .evenOdd
        maskLayer.path = path.cgPath
        layer.mask = maskLayer

        scanningBorder.path = UIBezierPath(
            roundedRect: scannableFrame,
            cornerRadius: 8
        ).cgPath
        scanningBorder.strokeColor = UIColor.white.cgColor
        scanningBorder.lineWidth = 8.0
        layer.addSublayer(scanningBorder)
    }
}
