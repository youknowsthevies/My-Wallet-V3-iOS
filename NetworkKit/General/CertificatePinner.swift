//
//  CertificatePinner.swift
//  Blockchain
//
//  Created by Maurice A. on 4/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ToolKit

@objc
final public class CertificatePinner: NSObject {

    // MARK: - Types

    private enum CertificatePinnerError: Error {
        case failedPreValidation
        case certificatesNotEqual
    }

    // MARK: - Properties

    /// The instance variable used to access functions of the `CertificatePinner` class.
    @objc public static let shared = CertificatePinner()

    /// Path to the local certificate file
    private lazy var localCertificatePath: String? = {
        Bundle(for: CertificatePinner.self).path(forResource: "blockchain", ofType: "der")
    }()

    /// Path to the local certificate file
    @objc public var certificateData: NSData? {
        guard let localCertificatePath = self.localCertificatePath else {
            return nil
        }
        return NSData(contentsOfFile: localCertificatePath)
    }
    
    private let session: URLSession

    // MARK: - Initialization

    //: Prevent outside objects from creating their own instances of this class.
    override public init() {
        self.session = Network.Dependencies.default.session
        super.init()
    }

    init(session: URLSession) {
        self.session = session
        super.init()
    }

    public func pinCertificateIfNeeded() {
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

    @objc
    public func didReceive(_ challenge: URLAuthenticationChallenge, completion: @escaping AuthChallengeHandler) {
        respond(to: challenge, completion: completion)
    }

    private func respond(to challenge: URLAuthenticationChallenge, completion: AuthChallengeHandler) {
        let policy = SecPolicyCreateBasicX509()
        var localTrust: SecTrust?

        guard
            let serverTrust = challenge.protectionSpace.serverTrust,
            let certificateData = self.certificateData,
            let localCertificate = SecCertificateCreateWithData(kCFAllocatorDefault, certificateData),
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
