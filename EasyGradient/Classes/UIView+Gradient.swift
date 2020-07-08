//
//  UIView+Extensions.swift
//  EasyGradient
//
//  Created by 姜振华 on 2020/4/13.
//

import Foundation
import UIKit

private var bgGradientAssociateKey: Void?
private var borderGradientAssociateKey: Void?
private var textGradientAssociateKey: Void?
private var progressGradientAssociateKey: Void?

public extension UIView {
    @objc var bgGradientOption: EGGradientBackgroundOption? {
        set {
            newValue?.associatedView = self
            objc_setAssociatedObject(self, &bgGradientAssociateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &bgGradientAssociateKey) as? EGGradientBackgroundOption
        }
    }
    
    @objc var borderGradientOption: EZGradientBorderOption? {
        set {
            newValue?.associatedView = self
            objc_setAssociatedObject(self, &borderGradientAssociateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &borderGradientAssociateKey) as? EZGradientBorderOption
        }
    }
}

public extension UILabel {
    @objc var textGradientOption: EZTextGradientOption? {
        set {
            newValue?.associatedView = self
            objc_setAssociatedObject(self, &textGradientAssociateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &textGradientAssociateKey) as? EZTextGradientOption
        }
    }
}

public extension UITextView {
    @objc var textGradientOption: EZTextGradientOption? {
        set {
            newValue?.associatedView = self
            objc_setAssociatedObject(self, &textGradientAssociateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &textGradientAssociateKey) as? EZTextGradientOption
        }
    }
}

public extension UITextField {
    @objc var textGradientOption: EZTextGradientOption? {
        set {
            newValue?.associatedView = self
            objc_setAssociatedObject(self, &textGradientAssociateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &textGradientAssociateKey) as? EZTextGradientOption
        }
    }
}

@propertyWrapper
public struct GradientWrapper<View: UIView> {
    let option: EZGradientOption
    let view: View
    
    public init(_ view: View, option: EZGradientOption) {
        self.option = option
        self.view = view
        self.option.associatedView = view
    }
    
    public var wrappedValue: View {
        return view
    }
}

public extension UIProgressView {
    @objc var progressGradientOption: EZProgressGradientOption? {
        set {
            newValue?.associatedView = self
            objc_setAssociatedObject(self, &progressGradientAssociateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &progressGradientAssociateKey) as? EZProgressGradientOption
        }
    }
}
