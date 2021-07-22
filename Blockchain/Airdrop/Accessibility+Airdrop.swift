// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

extension Accessibility.Identifier {
    enum AirdropCenterScreen {
        static let prefix = "AirdropCenterScreen."
        enum Cell {
            static let prefix = "\(AirdropCenterScreen.prefix)Cell."
            static let image = "\(prefix)image-"
            static let title = "\(prefix)title-"
            static let description = "\(prefix)description-"
        }
    }

    enum AirdropStatusScreen {
        private static let prefix = "AirdropStatusScreen."
        static let backgroundImageView = "\(prefix)backgroundImageView"
        static let thumbImageView = "\(prefix)thumbImageView"
        static let titleLabel = "\(prefix)titleLabel"
        static let descriptionLabel = "\(prefix)descriptionLabel"

        enum Cell {
            private static let prefix = "\(AirdropStatusScreen.prefix)Cell."
            enum Status {
                private static let prefix = "\(Cell.prefix)Status."
                static let title = "\(prefix)title"
                static let value = "\(prefix)value"
            }

            enum Amount {
                private static let prefix = "\(Cell.prefix)Amount."
                static let title = "\(prefix)title"
                static let value = "\(prefix)value"
            }

            enum Date {
                private static let prefix = "\(Cell.prefix)Date."
                static let title = "\(prefix)title"
                static let value = "\(prefix)value"
            }
        }
    }
}
