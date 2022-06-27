import SwiftUI

struct ImageAsset {
    static var iconExternalLink: Image {
        Image(
            "external-link-icon",
            bundle: .FeatureUserDeletion
        )
    }

    static var iconClose: Image {
        Image(
            "close-circle-icon",
            bundle: .FeatureUserDeletion
        )
    }

    static var iconInfo: Image {
        Image(
            "info-circle-icon",
            bundle: .FeatureUserDeletion
        )
    }

    enum Deletion {
        static var deletionFailed: Image {
            Image(
                "deletion-failed",
                bundle: .FeatureUserDeletion
            )
        }

        static var deletionSuceeded: Image {
            Image(
                "deletion-suceeded",
                bundle: .FeatureUserDeletion
            )
        }
    }
}

// MARK: Helper function

private class BundleFinder {}

extension Bundle {
    static let FeatureUserDeletion = Bundle.find(
        "FeatureUserDeletion_FeatureUserDeletionUI.bundle",
        in: BundleFinder.self
    )
}
