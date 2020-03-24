//
//  InstructionCellViewModel.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 11/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

/// Instruction cell view model
public struct InstructionCellViewModel {
    
    // MARK: - Properties
    
    /// The number of instruction
    let number: Int

    let numberViewModel: LabelContent
    
    /// The text view model
    let textViewModel: InteractableTextViewModel
    
    // MARK: - Setup
    
    public init(number: Int, inputs: [InteractableTextViewModel.Input]) {
        self.number = number
        numberViewModel = .init(
            text:  "\(number)",
            font: .mainBold(20),
            color: .titleText,
            alignment: .center,
            accessibility: .none
        )
        let font = UIFont.mainMedium(14)
        textViewModel = .init(
            inputs: inputs,
            textStyle: .init(color: .descriptionText, font: font),
            linkStyle: .init(color: .linkableText, font: font),
            lineSpacing: 7
        )
    }
}
