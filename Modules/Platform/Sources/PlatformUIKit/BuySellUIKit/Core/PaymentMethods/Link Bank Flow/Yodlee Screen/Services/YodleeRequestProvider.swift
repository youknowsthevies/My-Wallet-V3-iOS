// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

final class YodleeRequestProvider {

    /// Provides a `URLRequest` object for the webview using Yodlee integration
    /// seealso: https://developer.yodlee.com/docs/fastlink/4.0/mobile/ios
    func provideRequest(using data: BankLinkageData) -> URLRequest? {
        guard let urlString = data.fastlinkUrl, let token = data.token else {
            return nil
        }
        guard let url = URL(string: urlString) else {
            return nil
        }
        guard let configValue = data.fastlinkParams.config else {
            return nil
        }

        let intentUrl: String = Bundle.main.plist
            .BLOCKCHAIN_WALLET_PAGE_LINK[]
            .flatMap(URL.https)
            .or(default: "https://blockchainwallet.page.link")
            .appendingPathComponent("fastlink")
            .absoluteString

        guard let extraParams = "configName=\(configValue)&intentUrl=\(intentUrl)"
            .addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        else {
            return nil
        }

        var urlComponents = URLComponents()
        urlComponents.queryItems = [
            URLQueryItem(name: "accessToken", value: "Bearer \(token)"),
            URLQueryItem(name: "extraParams", value: extraParams)
        ]

        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        guard let query = urlComponents.query else {
            return nil
        }
        request.httpBody = query.data(using: .utf8)
        return request
    }
}
