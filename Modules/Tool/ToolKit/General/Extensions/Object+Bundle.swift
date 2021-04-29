// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol BundleRetrievable: AnyObject {

    /// Returns the object's class bundle. Particularly useful in registering resources
    /// that do not belong to the `Bundle.main`
    var bundle: Bundle { get }

    /// Returns the object's class bundle. Particularly useful in registering resources
    /// that do not belong to the `Bundle.main`
    static var bundle: Bundle { get }
}

extension BundleRetrievable {

    public var bundle: Bundle {
        Bundle(for: type(of: self))
    }

    public static var bundle: Bundle {
        Bundle(for: self)
    }
}

extension NSObject: BundleRetrievable { }
