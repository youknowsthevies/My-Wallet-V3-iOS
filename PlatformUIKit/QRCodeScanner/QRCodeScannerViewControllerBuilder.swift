//
//  QRCodeScannerViewControllerBuilder.swift
//  PlatformUIKit
//
//  Created by Jack on 18/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Foundation
import PlatformKit

public final class QRCodeScannerViewControllerBuilder<P: QRCodeScannerParsing> {

    public typealias CompletionHandler = ((Result<P.Success, P.Failure>) -> Void)
    
    private var scanner: QRCodeScanner? = QRCodeScanner()
    private var loadingViewPresenter: LoadingViewPresenting = resolve()
    private var loadingViewStyle: LoadingViewPresenter.LoadingViewStyle = .activityIndicator
    private var presentationType = QRCodePresentationType.modal(dismissWithAnimation: true)
    private var additionalParsingOptions: QRCodeScannerParsingOptions = .strict
    
    private let parser: P
    private let textViewModel: QRCodeScannerTextViewModel
    private let completed: CompletionHandler
    
    public init(parser: P, textViewModel: QRCodeScannerTextViewModel, completed: @escaping CompletionHandler) {
        self.parser = parser
        self.textViewModel = textViewModel
        self.completed = completed
    }
    
    public func with(loadingViewPresenter: LoadingViewPresenting,
                     style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator) -> QRCodeScannerViewControllerBuilder {
        self.loadingViewStyle = style
        self.loadingViewPresenter = loadingViewPresenter
        return self
    }
    
    public func with(presentationType: QRCodePresentationType) -> QRCodeScannerViewControllerBuilder {
        self.presentationType = presentationType
        return self
    }
    
    public func with(additionalParsingOptions: QRCodeScannerParsingOptions) -> QRCodeScannerViewControllerBuilder {
        self.additionalParsingOptions = additionalParsingOptions
        return self
    }
    
    public func build() -> UIViewController? {
        guard let scanner = scanner else { return nil }
        
        let vm = QRCodeScannerViewModel<P>(
            parser: parser,
            additionalParsingOptions: additionalParsingOptions,
            textViewModel: textViewModel,
            scanner: scanner,
            completed: completed
        )
        
        guard let qrCodeScannerViewModel = vm else { return nil }
        
        let scannerViewController = QRCodeScannerViewController(
            presentationType: presentationType,
            viewModel: qrCodeScannerViewModel,
            loadingViewPresenter: loadingViewPresenter,
            loadingViewStyle: loadingViewStyle
        )
        
        switch presentationType {
        case .modal:
            return UINavigationController(rootViewController: scannerViewController)
        case .child:
            return scannerViewController
        }
    }
}
