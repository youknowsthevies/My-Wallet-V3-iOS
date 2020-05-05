//
//  CompositeStatusView.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 30/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

public enum CompositeStatusViewType {
    
    public enum SideViewType {
        case image(String)
        case loader
        case none
    }
    
    case loader
    case image(String)
    case overlay(baseImageName: String, rightViewType: SideViewType)
    case none
}

public final class CompositeStatusView: UIView {

    final class ContainerView: UIView {
        
        // MARK: - Properties
        
        let currentTypeRelay = BehaviorRelay(value: CompositeStatusViewType.SideViewType.none)
        
        var currentType: Driver<CompositeStatusViewType.SideViewType> {
            currentTypeRelay.asDriver()
        }
        
        private let contentSizeRatio: CGFloat
        private let disposeBag = DisposeBag()
        
        // MARK: - Setup
        
        init(edge: CGFloat, contentSizeRatio: CGFloat = 0.80) {
            self.contentSizeRatio = contentSizeRatio
            let size = CGSize(edge: edge)
            super.init(frame: CGRect(origin: .zero, size: size))
            
            backgroundColor = .white
            
            currentType
                .drive(
                    onNext: { [weak self] type in
                        guard let self = self else { return }
                        self.removeSubviews()
                        switch type {
                        case .loader:
                            self.setupLoadingView()
                        case .image(let name):
                            self.setupImageView(with: name)
                        case .none:
                            break
                        }
                    })
                .disposed(by: disposeBag)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            layer.cornerRadius = min(bounds.width, bounds.height) * 0.5
        }

        private func setupImageView(with name: String) {
            let image = UIImage(named: name, in: .platformUIKit, compatibleWith: .none)!
            let imageView = UIImageView(image: image)
            add(view: imageView)
        }
        
        private func setupLoadingView() {
            let edge = bounds.width * contentSizeRatio
            let loadingView = LoadingAnimatingView(
                diameter: edge,
                strokeColor: .secondary,
                strokeBackgroundColor: UIColor.secondary.withAlphaComponent(0.3),
                fillColor: .clear,
                strokeWidth: 4
            )
            add(view: loadingView)
            loadingView.animate()
        }
        
        private func add(view: UIView) {
            addSubview(view)
            view.layoutToSuperviewSize(ratio: contentSizeRatio)
            view.layoutToSuperviewCenter()
        }
    }
    
    // MARK: - Properties
    
    public let currentTypeRelay = BehaviorRelay(value: CompositeStatusViewType.none)
    
    var currentType: Driver<CompositeStatusViewType> {
        currentTypeRelay.asDriver()
    }
    
    private let sideContainerView: UIView
    private let mainContainerView: UIView
    
    private let mainContainerViewRatio: CGFloat
    private let sideContainerViewRatio: CGFloat
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(edge: CGFloat, mainContainerViewRatio: CGFloat = 0.85) {
        self.mainContainerViewRatio = mainContainerViewRatio
        sideContainerViewRatio = 0.35
                
        let mainContainerViewEdge = edge * mainContainerViewRatio
        
        let sideContainerViewSize = CGSize(edge: edge * sideContainerViewRatio)
        
        sideContainerView = UIView(frame: CGRect(origin: .zero, size: sideContainerViewSize))
        mainContainerView = UIView(frame: CGRect(origin: .zero, size: CGSize(edge: mainContainerViewEdge)))

        let size = CGSize(edge: edge)
        
        super.init(frame: CGRect(origin: .zero, size: size))
        layout(size: size)
        
        layoutMainContainerView()
        layoutSideContainerView(edge: edge, mainContainerViewEdge: mainContainerViewEdge)
        sideContainerView.layout(size: sideContainerViewSize)

        currentType
            .drive(
                onNext: { [weak self] type in
                    guard let self = self else { return }
                    self.mainContainerView.removeSubviews()
                    self.sideContainerView.removeSubviews()
                    switch type {
                    case .image(let name):
                        self.setupImageView(with: name)
                    case .loader:
                        self.setupLoadingView()
                    case .overlay(baseImageName: let baseImageName, rightViewType: let rightViewType):
                        self.setupImageView(with: baseImageName)
                        self.setupRightView(with: rightViewType)
                    case .none:
                        break
                    }
                })
            .disposed(by: disposeBag)
    }
    
    private func layoutMainContainerView() {
        addSubview(mainContainerView)
        mainContainerView.layoutToSuperviewSize(ratio: mainContainerViewRatio)
        mainContainerView.layoutToSuperviewCenter()
    }
    
    private func layoutSideContainerView(edge: CGFloat, mainContainerViewEdge: CGFloat) {
        addSubview(sideContainerView)
        let space = (edge - mainContainerViewEdge) * 0.5
        let radius = mainContainerViewEdge * 0.5
        let sideContainerViewX = radius * cos(.pi * 0.125)
        let sideContainerViewY = -radius * sin(.pi * 0.25)
        sideContainerView.layoutToSuperview(.centerX, offset: sideContainerViewX - space)
        sideContainerView.layoutToSuperview(.centerY, offset: sideContainerViewY + space)
    }
    
    private func setupRightView(with type: CompositeStatusViewType.SideViewType) {
        let rightSideView = ContainerView(edge: sideContainerView.bounds.width)
        sideContainerView.addSubview(rightSideView)
        rightSideView.fillSuperview()
        rightSideView.currentTypeRelay.accept(type)
    }
    
    private func setupLoadingView() {
        let loadingView = LoadingAnimatingView(
            diameter: mainContainerView.bounds.width,
            strokeColor: .secondary,
            strokeBackgroundColor: UIColor.secondary.withAlphaComponent(0.3),
            fillColor: .clear
        )
        add(view: loadingView)
        loadingView.animate()        
    }
    
    private func setupImageView(with name: String) {
        let image = UIImage(named: name, in: .platformUIKit, compatibleWith: .none)!
        let imageView = UIImageView(image: image)
        add(view: imageView)
    }
    
    private func add(view: UIView) {
        mainContainerView.addSubview(view)
        view.layoutToSuperviewSize(ratio: mainContainerViewRatio)
        view.layoutToSuperviewCenter()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
