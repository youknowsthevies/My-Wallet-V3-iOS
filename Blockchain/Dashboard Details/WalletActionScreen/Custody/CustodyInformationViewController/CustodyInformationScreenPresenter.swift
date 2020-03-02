//
//  CustodySendInformationScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 2/3/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift

final class CustodyInformationScreenPresenter {
    
    private typealias AccessibilityId = Accessibility.Identifier.CustodyInfo
    
    // MARK: - Navigation Properties
    
    var trailingButton: Screen.Style.TrailingButton {
        return .content(.init(title: nil, image: #imageLiteral(resourceName: "cancel_icon"), accessibility: .id(AccessibilityId.backButton)))
    }
    
    var leadingButton: Screen.Style.LeadingButton {
        return .none
    }
    
    var titleView: Screen.Style.TitleView {
        return .text(value: LocalizationID.title)
    }
    
    var barStyle: Screen.Style.Bar {
        return .darkContent(ignoresStatusBar: false, background: .white)
    }
    
    private typealias LocalizationID = LocalizationConstants.CustodyWalletInformation
    
    // MARK: - Public Properites
    
    var description: LabelContent {
        return .init(
            text: LocalizationID.Description.partOne,
            font: .mainMedium(14.0),
            color: .textFieldText,
            alignment: .left,
            accessibility: .id(AccessibilityId.descriptionLabel)
        )
    }
    
    var subDescription: LabelContent {
        return .init(
            text: LocalizationID.Description.partTwo,
            font: .mainMedium(14.0),
            color: .textFieldText,
            alignment: .left,
            accessibility: .id(AccessibilityId.subDescriptionLabel)
        )
    }
    
    let okButtonViewModel: ButtonViewModel
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    private unowned let stateService: CustodyActionStateServiceAPI
    
    init(stateService: CustodyActionStateServiceAPI) {
        self.stateService = stateService
        okButtonViewModel = .primary(with: LocalizationConstants.okString, accessibilityId: AccessibilityId.okButton)
        okButtonViewModel.tapRelay
            .bind(to: stateService.nextRelay)
            .disposed(by: disposeBag)
    }
    
    func navigationBarTrailingButtonTapped() {
        stateService.previousRelay.accept(())
    }
}

fileprivate extension Accessibility.Identifier {
    enum CustodyInfo {
        private static let prefix = "CustodyInfoScreen."
        static let backButton = "\(prefix)backButton"
        static let descriptionLabel = "\(prefix)descriptionLabel"
        static let subDescriptionLabel = "\(prefix)subDescriptionLabel"
        static let okButton = "\(prefix)okButton"
    }
}
