// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// `WalletIntroductionLocation` denotes the screen as well as the
/// location that the event should map to. This is saved in the file system
/// as the user completes introduction events so that we know where the user
/// left off.
public struct WalletIntroductionLocation: Codable, Comparable {

    public enum Screen: Int, Codable, Comparable {
        case dashboard
        case sideMenu
    }

    public enum Position: Int, Codable, Comparable {
        case home
        case send
        case receive
        case swap
    }

    public let screen: Screen
    public let position: Position

    public init(screen: Screen, position: Position) {
        self.screen = screen
        self.position = position
    }
}

extension WalletIntroductionLocation {
    public static func < (lhs: WalletIntroductionLocation, rhs: WalletIntroductionLocation) -> Bool {
        if lhs.screen == rhs.screen {
            return lhs.position < rhs.position
        } else {
            return lhs.screen < rhs.screen
        }
    }

    public static func > (lhs: WalletIntroductionLocation, rhs: WalletIntroductionLocation) -> Bool {
        if lhs.screen == rhs.screen {
            return lhs.position > rhs.position
        } else {
            return lhs.screen > rhs.screen
        }
    }
}

extension WalletIntroductionLocation.Screen {
    public static func < (lhs: WalletIntroductionLocation.Screen, rhs: WalletIntroductionLocation.Screen) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public static func > (lhs: WalletIntroductionLocation.Screen, rhs: WalletIntroductionLocation.Screen) -> Bool {
        lhs.rawValue > rhs.rawValue
    }
}

extension WalletIntroductionLocation.Position {
    public static func < (lhs: WalletIntroductionLocation.Position, rhs: WalletIntroductionLocation.Position) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public static func > (lhs: WalletIntroductionLocation.Position, rhs: WalletIntroductionLocation.Position) -> Bool {
        lhs.rawValue > rhs.rawValue
    }
}
