// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureQRCodeScannerData
import FeatureQRCodeScannerDomain
import Localization
import PlatformKit
import PlatformUIKit

protocol QRCodeScannerViewModelProtocol: AnyObject {
    var scanningStarted: (() -> Void)? { get set }
    var scanningStopped: (() -> Void)? { get set }
    var closeButtonTapped: (() -> Void)? { get set }
    var scanComplete: ((Result<QRCodeScannerResultType, QRCodeScannerResultError>) -> Void)? { get set }
    var completed: (Result<QRCodeScannerResultType, QRCodeScannerResultError>) -> Void { get set }

    var videoPreviewLayer: CALayer? { get }
    var headerText: String { get }
    var overlayViewModel: QRCodeScannerOverlayViewModel { get }

    func closeButtonPressed()
    func startReadingQRCode(from scannableArea: QRCodeScannableArea)

    func viewWillDisappear()
    func handleSelectedQRImage(_ image: UIImage)
}

public enum QRCodeScannerParsingOptions {
    /// Strict approach, only act on the link using the given parser
    case strict

    /// Lax parsing, allow acting on other routes at well
    case lax(routes: [DeepLinkRoute])
}

final class QRCodeScannerViewModel: QRCodeScannerViewModelProtocol {
    typealias CompletionHandler = (Result<QRCodeScannerResultType, QRCodeScannerResultError>) -> Void

    var scanningStarted: (() -> Void)?
    var scanningStopped: (() -> Void)?
    var closeButtonTapped: (() -> Void)?
    var scanComplete: CompletionHandler?
    var completed: CompletionHandler

    let overlayViewModel: QRCodeScannerOverlayViewModel

    var videoPreviewLayer: CALayer? {
        scanner.videoPreviewLayer
    }

    var headerText: String {
        LocalizationConstants.scanQRCode
    }

    private let types: [QRCodeScannerType]
    private let scanner: QRCodeScannerProtocol
    private let cryptoTargetParser: CryptoTargetQRCodeParser
    private let deepLinkParser: DeepLinkQRCodeParser
    private let secureChannelParser: SecureChannelQRCodeParser
    private let parsingSubject = CurrentValueSubject<Bool, Never>(false)
    private var cancellables = [AnyCancellable]()

    init(
        types: [QRCodeScannerType],
        additionalParsingOptions: QRCodeScannerParsingOptions = .strict,
        supportsCameraRoll: Bool,
        scanner: QRCodeScannerProtocol,
        completed: @escaping CompletionHandler,
        deepLinkHandler: DeepLinkHandling = resolve(),
        deepLinkRouter: DeepLinkRouting = resolve(),
        secureChannelService: SecureChannelAPI = resolve(),
        adapter: CryptoTargetQRCodeParserAdapter = resolve()
    ) {
        let additionalLinkRoutes: [DeepLinkRoute]
        switch additionalParsingOptions {
        case .lax(routes: let routes):
            additionalLinkRoutes = routes
        case .strict:
            additionalLinkRoutes = []
        }
        let deepLinkQRCodeRouter = DeepLinkQRCodeRouter(
            supportedRoutes: additionalLinkRoutes,
            deepLinkHandler: deepLinkHandler,
            deepLinkRouter: deepLinkRouter
        )
        let sourceAccount: CryptoAccount? = types
            .firstNonNil { type in
                switch type {
                case .cryptoTarget(let sourceAccount):
                    return sourceAccount
                case .deepLink, .walletConnect:
                    return nil
                }
            }

        cryptoTargetParser = CryptoTargetQRCodeParser(
            account: sourceAccount,
            adapter: adapter
        )
        deepLinkParser = DeepLinkQRCodeParser(deepLinkQRCodeRouter: deepLinkQRCodeRouter)
        secureChannelParser = SecureChannelQRCodeParser(secureChannelService: secureChannelService)

        self.types = types
        self.scanner = scanner
        self.completed = completed
        overlayViewModel = .init(supportsCameraRoll: supportsCameraRoll, titleText: LocalizationConstants.scanQRCode)

        scanner.qrCodePublisher
            .withLatestFrom(parsingSubject.eraseToAnyPublisher()) { ($0, !$1) }
            .filter(\.1)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.parsingSubject.send(true)
            })
            .map { [weak self] scanResult, _ -> [AnyPublisher<QRCodeScannerResultType?, Never>]? in
                guard let self = self else { return nil }
                return [
                    self.cryptoTargetParser.parse(scanResult: scanResult)
                        .optional()
                        .replaceError(with: nil)
                        .eraseToAnyPublisher(),
                    self.secureChannelParser.parse(scanResult: scanResult)
                        .optional()
                        .replaceError(with: nil)
                        .eraseToAnyPublisher()
                ]
            }
            .flatMap { results -> AnyPublisher<QRCodeScannerResultType?, Never> in
                if let results = results {
                    return results
                        .zip()
                        .map { result in result.compactMap { $0 }.first }
                        .eraseToAnyPublisher()
                }
                return AnyPublisher.just(nil)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                guard let self = self else { return }
                if let result = result {
                    self.scanComplete?(.success(result))
                } else {
                    self.scanComplete?(.failure(.scannerError(QRScannerError.badMetadataObject)))
                    self.overlayViewModel.scanSuccess.send(.failure(QRScannerError.badMetadataObject))
                    self.parsingSubject.send(false)
                }
            })
            .store(in: &cancellables)

        parsingSubject
            .eraseToAnyPublisher()
            .dropFirst()
            .sink { [weak self] in
                guard !$0 else { return }
                self?.scanner.restartScanning()
            }
            .store(in: &cancellables)
    }

    func viewWillDisappear() {
        scanner.stopReadingQRCode(complete: nil)
    }

    func closeButtonPressed() {
        scanner.stopReadingQRCode(complete: nil)
        closeButtonTapped?()
    }

    func startReadingQRCode(from scannableArea: QRCodeScannableArea) {
        scanner.startReadingQRCode(from: scannableArea)
    }

    func handleSelectedQRImage(_ image: UIImage) {
        scanner.handleSelectedQRImage(image)
    }
}

extension QRCodeScannerViewModel: QRCodeScannerDelegate {
    func didStartScanning() {
        scanningStarted?()
    }

    func didStopScanning() {
        scanningStopped?()
    }
}
