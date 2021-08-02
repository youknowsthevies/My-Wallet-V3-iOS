// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

@testable import PlatformKit
import XCTest

class SupportedAssetsLocalServiceTests: XCTestCase {

    var fileProviderMock: SupportedAssetsLocalFilePathProviderMock!
    var sut: SupportedAssetsLocalServiceAPI!

    override func setUp() {
        fileProviderMock = SupportedAssetsLocalFilePathProviderMock()
        sut = SupportedAssetsLocalService(errorLogger: MockErrorRecorder(), filePathProvider: fileProviderMock)
    }

    override func tearDown() {
        fileProviderMock = nil
        sut = nil
    }

    func testDecodesFromRemoteFile() {
        fileProviderMock.remoteERC20Assets = createValidFile()
        XCTAssertNoThrow(try sut.erc20Asset.get())
    }

    func testDecodesFromLocalFileIfRemoteMissing() {
        fileProviderMock.localERC20Assets = createValidFile()
        XCTAssertNoThrow(try sut.erc20Asset.get())
    }

    func testDecodesFromLocalFileIfRemoteMalformed() {
        fileProviderMock.remoteERC20Assets = createEmptyFile()
        fileProviderMock.localERC20Assets = createValidFile()
        XCTAssertNoThrow(try sut.erc20Asset.get())
    }

    func testThrowsIfRemoteMalformedAndLocalIsMalformed() {
        fileProviderMock.remoteERC20Assets = createEmptyFile()
        fileProviderMock.localERC20Assets = createEmptyFile()
        XCTAssertThrowsError(try sut.erc20Asset.get()) { error in
            switch error {
            case SupportedAssetsLocalError.localDecodingFailed:
                break
            default:
                XCTFail("Got \(error)")
            }
        }
    }

    func testThrowsIfRemoteMissingAndLocalIsMalformed() {
        fileProviderMock.localERC20Assets = createEmptyFile()
        XCTAssertThrowsError(try sut.erc20Asset.get()) { error in
            switch error {
            case SupportedAssetsLocalError.localDecodingFailed:
                break
            default:
                XCTFail("Got \(error)")
            }
        }
    }

    func testThrowsIfRemoteAndLocalAreMissing() {
        XCTAssertThrowsError(try sut.erc20Asset.get()) { error in
            switch error {
            case SupportedAssetsLocalError.missingLocalFile:
                break
            default:
                XCTFail("Got \(error)")
            }
        }
    }

    private func createValidFile() -> String {
        let dirPath = NSTemporaryDirectory()
        let uuid = UUID().uuidString
        let filePath = "\(dirPath)/\(uuid).json"
        FileManager.default.createFile(
            atPath: filePath,
            contents: "{\"currencies\":[]}".data(using: .utf8)
        )
        return filePath
    }

    private func createEmptyFile() -> String {
        let dirPath = NSTemporaryDirectory()
        let uuid = UUID().uuidString
        let filePath = "\(dirPath)/\(uuid).json"
        FileManager.default.createFile(
            atPath: filePath,
            contents: "".data(using: .utf8)
        )
        return filePath
    }
}
