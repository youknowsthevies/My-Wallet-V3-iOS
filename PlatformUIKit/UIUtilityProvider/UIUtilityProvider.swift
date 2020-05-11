//
//  UIUtilityProvider.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 05/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public final class UIUtilityProvider: UIUtilityProviderAPI {
    
    /// The default instance of the provider
    public static let `default`: UIUtilityProviderAPI = UIUtilityProvider()
    
    public let alert: AlertViewPresenterAPI
    public let loader: LoadingViewPresenting
    
    init(alert: AlertViewPresenterAPI = AlertViewPresenter.shared,
         loader: LoadingViewPresenting = LoadingViewPresenter.shared) {
        self.alert = alert
        self.loader = loader
    }
}
