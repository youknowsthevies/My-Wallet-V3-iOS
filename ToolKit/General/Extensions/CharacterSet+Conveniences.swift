//
//  CharacterSet+Conveniences.swift
//  ToolKit
//
//  Created by Daniel Huri on 28/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension CharacterSet {
    public func contains(_ character: Character) -> Bool {
        return !character.unicodeScalars.contains(where: { !contains($0) })
    }
}
