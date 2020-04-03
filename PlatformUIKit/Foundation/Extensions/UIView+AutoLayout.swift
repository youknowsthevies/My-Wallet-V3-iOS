//
//  UIView+AutoLayout.swift
//  Blockchain
//
//  Created by Daniel Huri on 30/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit

public extension UILayoutPriority {
    /// Owns `999` as value, one prior to the highest (`1000`) that can still be changed w/o crashing
    static let penultimateHigh = UILayoutPriority(rawValue: 999)
    static let penultimateLow = UILayoutPriority(rawValue: 1)
}

extension UIView {
    
    // MARK: - Types
    
    public typealias Priority = UILayoutPriority
    public typealias Attribute = NSLayoutConstraint.Attribute
    public typealias Relation = NSLayoutConstraint.Relation
    public typealias Constraints = [Attribute: NSLayoutConstraint]
    
    /// A frame that comprise a center and size
    public struct Frame {
        public let center: LayoutForm.Constraints
        public let size: LayoutForm.Constraints
    }
    
    /// A layout from
    public enum LayoutForm {
        
        /// Center layout form
        case center
        
        /// Size layout form
        case size
        
        public struct Constraints {
            public let horizontal: NSLayoutConstraint
            public let vertical: NSLayoutConstraint
        }
        
        fileprivate var attributes: (horizontal: Attribute, vertical: Attribute) {
            let horizontal: Attribute
            let vertical: Attribute
            
            switch self {
            case .size:
                horizontal = .width
                vertical = .height
            case .center:
                horizontal = .centerX
                vertical = .centerY
            }
            return (horizontal: horizontal, vertical: vertical)
        }
    }
    
    /// Describes an axis
    public enum Axis {
        case horizontal
        case vertical
        
        public struct Constraints {
            public let leading: NSLayoutConstraint
            public let trailing: NSLayoutConstraint
        }
        
        fileprivate var attributes: (leading: Attribute, trailing: Attribute) {
            let leading: Attribute
            let trailing: Attribute
            
            switch self {
            case .horizontal:
                leading = .leading
                trailing = .trailing
            case .vertical:
                leading = .top
                trailing = .bottom
            }
            return (leading: leading, trailing: trailing)
        }
    }

    public enum Dimension {
        case width
        case height

        fileprivate var attribute: Attribute {
            switch self {
            case .width:
                return .width
            case .height:
                return .height
            }
        }
    }

    // MARK: - Content Hugging Priority
    
    public var horizontalContentHuggingPriority: Priority {
        set {
            setContentHuggingPriority(newValue, for: .horizontal)
        }
        get {
            return contentHuggingPriority(for: .horizontal)
        }
    }
    
    public var verticalContentHuggingPriority: Priority {
        set {
            setContentHuggingPriority(newValue, for: .vertical)
        }
        get {
            return contentHuggingPriority(for: .vertical)
        }
    }

    public var contentHuggingPriority: (horizontal: Priority, vertical: Priority) {
        set {
            horizontalContentHuggingPriority = newValue.horizontal
            verticalContentHuggingPriority = newValue.vertical
        }
        get {
            return (horizontalContentHuggingPriority, verticalContentHuggingPriority)
        }
    }
    
    // MARK: - Content Compression Resistance Priority
    
    public var verticalContentCompressionResistancePriority: Priority {
        set {
            setContentCompressionResistancePriority(newValue, for: .vertical)
        }
        get {
            return contentCompressionResistancePriority(for: .vertical)
        }
    }
    
    public var horizontalContentCompressionResistancePriority: Priority {
        set {
            setContentCompressionResistancePriority(newValue, for: .horizontal)
        }
        get {
            return contentCompressionResistancePriority(for: .horizontal)
        }
    }
    
    public var contentCompressionResistancePriority: (horizontal: Priority, vertical: Priority) {
        set {
            horizontalContentCompressionResistancePriority = newValue.horizontal
            verticalContentCompressionResistancePriority = newValue.vertical
        }
        get {
            return (horizontalContentCompressionResistancePriority, verticalContentCompressionResistancePriority)
        }
    }
    
    public func maximizeResistanceAndHuggingPriorities() {
        contentCompressionResistancePriority = (horizontal: .required, vertical: .required)
        contentHuggingPriority = (horizontal: .required, vertical: .required)
    }

    /// Layout width and height to a specific value
    @discardableResult
    public func layout(size: CGSize,
                       relation: Relation = .equal,
                       ratio: CGFloat = 1.0,
                       priority: Priority = .required) -> LayoutForm.Constraints {
        let width = layout(dimension: .width, to: size.width, relation: relation, ratio: ratio, priority: priority)
        let height = layout(dimension: .height, to: size.height, relation: relation, ratio: ratio, priority: priority)
        return .init(horizontal: width, vertical: height)
    }

    /// Layout width or height to a specific value
    @discardableResult
    public func layout(dimension: Dimension,
                       to value: CGFloat,
                       relation: Relation = .equal,
                       ratio: CGFloat = 1.0,
                       priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: dimension.attribute,
            relatedBy: relation,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: ratio,
            constant: value
        )
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    public func layout(edge: Attribute? = nil,
                       to otherEdge: Attribute,
                       of view: UIView,
                       relation: Relation = .equal,
                       ratio: CGFloat = 1.0,
                       offset: CGFloat = 0,
                       priority: UILayoutPriority = .required,
                       activate: Bool = true) -> NSLayoutConstraint? {
        guard prepareForAutoLayout() else {
            assertionFailure("\(String(describing: self)) Error in func: \(#function)")
            return nil
        }
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: edge ?? otherEdge,
            relatedBy: relation,
            toItem: view,
            attribute: otherEdge,
            multiplier: ratio,
            constant: offset
        )
        constraint.priority = priority
        constraint.isActive = activate
        return constraint
    }
    
    @discardableResult
    public func layout(edges: Attribute...,
                       to view: UIView,
                       relation: Relation = .equal,
                       ratio: CGFloat = 1.0,
                       offset: CGFloat = 0,
                       priority: UILayoutPriority = .required) -> Constraints {
        var constraints: Constraints = [:]
        guard prepareForAutoLayout() else {
            assertionFailure("\(String(describing: self)) Error in func: \(#function)")
            return constraints
        }
        let uniqueEdges = Set(edges)
        for edge in uniqueEdges {
            let constraint = NSLayoutConstraint(
                item: self,
                attribute: edge,
                relatedBy: relation,
                toItem: view,
                attribute: edge,
                multiplier: ratio,
                constant: offset
            )
            constraint.priority = priority
            constraint.isActive = true
            constraints[edge] = constraint
        }
        return constraints
    }
    
    @discardableResult
    public func layoutToSuperview(_ edge: Attribute,
                                  relation: Relation = .equal,
                                  ratio: CGFloat = 1,
                                  offset: CGFloat = 0,
                                  priority: Priority = .required) -> NSLayoutConstraint? {
        guard prepareForAutoLayout() else {
            assertionFailure("\(String(describing: self)) Error in func: \(#function)")
            return nil
        }
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: edge,
            relatedBy: relation,
            toItem: superview,
            attribute: edge,
            multiplier: ratio,
            constant: offset
        )
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    public func layoutToSuperview(_ edges: Attribute...,
                                  relation: Relation = .equal,
                                  ratio: CGFloat = 1,
                                  offset: CGFloat = 0,
                                  priority: Priority = .required) -> Constraints {
        var constraints: Constraints = [:]
        guard !edges.isEmpty && prepareForAutoLayout() else {
            return constraints
        }
        let uniqueEdges = Set(edges)
        for edge in uniqueEdges {
            let constraint = NSLayoutConstraint(
                item: self,
                attribute: edge,
                relatedBy: relation,
                toItem: superview,
                attribute: edge,
                multiplier: ratio,
                constant: offset
            )
            constraint.priority = priority
            constraint.isActive = true
            constraints[edge] = constraint
        }
        return constraints
    }
    
    @discardableResult
    public func layoutToSuperview(axis: Axis,
                                  offset: CGFloat = 0,
                                  priority: Priority = .required) -> Axis.Constraints? {
        let attributes = axis.attributes
        guard let leading = layoutToSuperview(attributes.leading, offset: offset, priority: priority) else {
            return nil
        }
        guard let trailing = layoutToSuperview(attributes.trailing, offset: -offset, priority: priority) else {
            return nil
        }
        return .init(leading: leading, trailing: trailing)
    }
    
    @discardableResult
    public func layoutToSuperviewCenter(priority: Priority = .required) -> LayoutForm.Constraints? {
        guard let centerX = layoutToSuperview(.centerX, priority: priority) else {
            return nil
        }
        guard let centerY = layoutToSuperview(.centerY, priority: priority) else {
            return nil
        }
        return .init(horizontal: centerX, vertical: centerY)
    }
    
    @discardableResult
    public func layoutToSuperviewSize(ratio: CGFloat = 1,
                                      offset: CGFloat = 0,
                                      priority: Priority = .required) -> LayoutForm.Constraints? {
        guard let width = layoutToSuperview(.width, ratio: ratio, offset: offset, priority: priority) else {
            return nil
        }
        guard let height = layoutToSuperview(.height, ratio: ratio, offset: offset, priority: priority) else {
            return nil
        }
        return .init(horizontal: width, vertical: height)
    }
    
    @discardableResult
    public func fillSuperview() -> Frame? {
        guard let center = layoutToSuperviewCenter() else { return nil }
        guard let size = layoutToSuperviewSize() else { return nil }
        return .init(center: center, size: size)
    }
    
    // MARK: - Private Methods
    
    private func prepareForAutoLayout() -> Bool {
        guard superview != nil else {
            assertionFailure("\(String(describing: self)):\(#function) - superview is unexpectedly nullified")
            return false
        }
        translatesAutoresizingMaskIntoConstraints = false
        return true
    }
}
