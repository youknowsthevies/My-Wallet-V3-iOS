// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum MainBundleProvider {
    public static var mainBundle: Bundle = {
        var bundle = Bundle.main
        if bundle.bundleURL.pathExtension == "appex" {
            // If this is an App Extension (Today Extension), move up two directory levels
            // - MY_APP.app/PlugIns/MY_APP_EXTENSION.appex
            let url = bundle.bundleURL.deletingLastPathComponent().deletingLastPathComponent()
            if let otherBundle = Bundle(url: url) {
                bundle = otherBundle
            }
        }
        return bundle
    }()
}
