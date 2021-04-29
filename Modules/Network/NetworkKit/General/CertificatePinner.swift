// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ToolKit

@objc public protocol CertificatePinnerAPI {
    
    var certificateData: Data? { get }
    
    func pinCertificateIfNeeded()
    
    func didReceive(_ challenge: URLAuthenticationChallenge, completion: @escaping AuthChallengeHandler)
}

final class CertificatePinner: CertificatePinnerAPI {

    // MARK: - Types

    private enum CertificatePinnerError: Error {
        case failedPreValidation
        case certificatesNotEqual
    }

    // MARK: - Properties
    
    /// Certificate Data
    var certificateData: Data? {
        guard let certificateURL = localCertificateURL else {
            return nil
        }
        return try? Data(contentsOf: certificateURL)
    }
    
    /// Path to the local certificate file
    private lazy var localCertificateURL: URL? = {
        Bundle(for: CertificatePinner.self).url(forResource:"blockchain", withExtension: "der")
    }()
    
    private let session: URLSession

    // MARK: - Initialization

    init(session: URLSession = resolve()) {
        self.session = session
    }

    func pinCertificateIfNeeded() {
        guard BlockchainAPI.shared.shouldPinCertificate else {
            return
        }
        let walletUrl = BlockchainAPI.shared.walletUrl
        guard let url = URL(string: walletUrl) else {
            fatalError("Failed to get wallet url from Bundle.")
        }
        session.sessionDescription = url.host
        // TODO: inject NetworkCommunicator
        let task = session.dataTask(with: url) { _, _, _ in }
        task.resume()
    }

    func didReceive(_ challenge: URLAuthenticationChallenge, completion: @escaping AuthChallengeHandler) {
        respond(to: challenge, completion: completion)
    }

    private func respond(to challenge: URLAuthenticationChallenge, completion: AuthChallengeHandler) {
        let policy = SecPolicyCreateBasicX509()
        var localTrust: SecTrust?

        guard
            let serverTrust = challenge.protectionSpace.serverTrust,
            let certificateData = self.certificateData,
            let localCertificate = SecCertificateCreateWithData(kCFAllocatorDefault, certificateData as NSData),
            SecTrustCreateWithCertificates(localCertificate, policy, &localTrust) == errSecSuccess
        else {
            Logger.shared.error(CertificatePinnerError.failedPreValidation)
            completion(.cancelAuthenticationChallenge, nil)
            return
        }

        let localPublicKey = SecTrustCopyPublicKey(localTrust!)
        let serverPublicKey = SecTrustCopyPublicKey(serverTrust)
        if (localPublicKey as AnyObject).isEqual(serverPublicKey as AnyObject) {
            let credential = URLCredential(trust: serverTrust)
            completion(.useCredential, credential)
        } else {
            Logger.shared.error(CertificatePinnerError.certificatesNotEqual)
            completion(.cancelAuthenticationChallenge, nil)
        }
    }
}
