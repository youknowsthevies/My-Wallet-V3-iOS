// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import LibWally

public struct WordList {
    
    private struct Languages {
        
        public static let english = WordList(words: BIP39Words)
    }
    
    public static let `default` = Languages.english
    
    public let words: [String]
    
    private init(words: [String]) {
        self.words = words
    }
    
}
