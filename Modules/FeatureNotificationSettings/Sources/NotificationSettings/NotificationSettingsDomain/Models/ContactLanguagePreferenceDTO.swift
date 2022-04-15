//
//  File.swift
//  
//
//  Created by Augustin Udrea on 15/04/2022.
//

import Foundation

public struct ContactLanguagePreferenceDTO: Encodable {
    let language: String

    public init(language: String) {
        self.language = language
    }
}
