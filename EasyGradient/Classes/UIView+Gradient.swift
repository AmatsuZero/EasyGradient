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
