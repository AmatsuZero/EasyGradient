//
//  GradientOption.swift
//  EasyGradient
//
//  Created by 姜振华 on 2020/4/13.
//

import Foundation
import UIKit

/// 渐变方向
@objc public enum EZGradientDirection: Int {
    /// 从上到下
    case topToBottom
    /// 从左到右
    case leftToRight
    /// 从左上到右下
    case leftTopToRightBottom
    /// 从左下到右上
    case leftBottomToRightTop
    
    func convert(size: CGSize) -> (start: CGPoint, end: CGPoint) {
        var start = CGPoint.zero
        var end = CGPoint.zero
        switch self {
        case .topToBottom:
            start = CGPoint(x: size.width / 2, y: 0)
            end = CGPoint(x: size.width / 2, y: size.height)
        case .leftToRight:
            start = CGPoint(x: 0, y: size.height / 2)
            end = CGPoint(x: size.width, y: size.height / 2)
        case .leftTopToRightBottom:
            end = CGPoint(x: size.width, y: 0)
        case .leftBottomToRightTop:
            start = CGPoint(x: 0, y: size.height)
            end = CGPoint(x: size.width, y: 0)
        }
        return (start, end)
    }
}

/// 渐变模式
@objc public enum EZGradientMode: Int {
    /// 线性
    case linear
    /// 辐射
    case radial
    
    func asGradientLayerType() -> String {
        switch self {
        case .radial: return "radial"
        default: return "axial"
        }
    }
}

@objc
@objcMembers public class EZGradientOption: NSObject, NSCopying {
    /// 此时是否可以更新颜色
    fileprivate var canUpdate = true
    /// 渐变颜色
    public var colors: [UIColor]?
    /// 渐变色尺寸
    public var size = CGSize.zero {
        didSet {
            canUpdate = false
            if let direction = direction {
                let (start, end) = direction.convert(size: size)
                self.start = start
                self.end = end
            }
            canUpdate = true
            updateGradient()
        }
    }
    /// An array of `UIColor` objects used to draw the dimmed gradient. If the value is `nil`, `colors` will be
    /// converted to grayscale. This will use the same `locations` as `colors`. If length of arrays don't match, bad
    /// things will happen. You must make sure the number of dimmed colors equals the number of regular colors.
    ///
    /// The default is `nil`.
    public var dimmedColors: [UIColor]? {
        didSet {
            updateGradient()
        }
    }
    /// Automatically dim gradient colors when prompted by the system (i.e. when an alert is shown).
    public var automaticallyDims: Bool = true
    /// 起始位置
    public var start = CGPoint.zero {
        didSet {
            updateGradient()
        }
    }
    /// 结束位置
    public var end = CGPoint.zero {
        didSet {
            updateGradient()
        }
    }
    /// 每个渐变色的停止位置
    public var locations: [CGFloat]? {
        didSet {
            updateGradient()
        }
    }
    /// 渐变模式
    public var mode = EZGradientMode.linear {
        didSet {
            updateGradient()
        }
    }
    /// 渐变色位置
    public var drawOptions: CGGradientDrawingOptions = CGGradientDrawingOptions() {
        didSet {
            updateGradient()
        }
    }
    /// KVO 观察者
    var observer: NSKeyValueObservation?
    /// 关联变化的视图
    public weak var associatedView: UIView? {
        didSet {
            observer = associatedView?.observe(\UIView.frame, changeHandler: { [weak self] view, value in
                guard let self = self else {
                    return
                }
                self.size = view.frame.size
            })
            updateGradient()
        }
    }
    
    public var direction: EZGradientDirection? {
        didSet {
            canUpdate = false
            if let newValue = direction {
                let (start, end) = newValue.convert(size: size)
                self.start = start
                self.end = end
            }
            canUpdate = true
            updateGradient()
        }
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let option = EZGradientOption()
        option.colors = colors
        option.dimmedColors = dimmedColors
        option.size = size
        option.drawOptions = drawOptions
        option.locations = locations
        option.start = start
        option.end = end
        option.mode = mode
        option.automaticallyDims = automaticallyDims
        return option
    }
    
    func updateGradient() {}
    
    func gradientColors(isDimmed: Bool) -> [UIColor]? {
        if isDimmed {
            if let colors = dimmedColors {
                return colors
            }
            if automaticallyDims {
                return colors?.map {
                    var hue: CGFloat = 0
                    var brightness: CGFloat = 0
                    var alpha: CGFloat = 0
                    $0.getHue(&hue, saturation: nil, brightness: &brightness, alpha: &alpha)
                    return UIColor(hue: hue, saturation: 0, brightness: brightness, alpha: alpha)
                }
            }
        }
        return colors
    }
    
    public func asCGGradient(isDimmed: Bool) -> CGGradient? {
        guard let colors = gradientColors(isDimmed: isDimmed) else {
            return nil
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorSpaceModel = colorSpace.model
        let gradientColors = colors.map { (color: UIColor) -> AnyObject in
            let cgColor = color.cgColor
            let cgColorSpace = cgColor.colorSpace ?? colorSpace
            // The color's color space is RGB, simply add it.
            if cgColorSpace.model == colorSpaceModel {
                return cgColor as AnyObject
            }
            // Convert to RGB. There may be a more efficient way to do this.
            var red: CGFloat = 0
            var blue: CGFloat = 0
            var green: CGFloat = 0
            var alpha: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor as AnyObject
        } as NSArray
        return CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: locations)
    }
    
    public func asColor() -> UIColor? {
        return UIColor.gradientColor(with: self)
    }
    
    func drawGradient(_ ctx: CGContext, glossGradient: CGGradient) {
        switch mode {
        case .linear:
            ctx.drawLinearGradient(glossGradient, start: start, end: end, options: drawOptions)
        case .radial:
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            ctx.drawRadialGradient(glossGradient, startCenter: start,
                                   startRadius: 0, endCenter: center,
                                   endRadius: min(size.width, size.height) / 2, options: drawOptions)
        }
    }
    
    public func asGradientLayer(isDimmed: Bool = false) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = gradientColors(isDimmed: isDimmed)?.map { $0.cgColor }
        layer.locations = locations?.map { $0 as NSNumber }
        layer.endPoint = end
        layer.startPoint = start
        layer.type = mode.asGradientLayerType()
        layer.frame = CGRect(origin: .zero, size: size)
        return layer
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        if self === object as AnyObject? {
            return true
        }
        guard let another = object as? EZGradientOption else {
            return false
        }
        return another.mode == mode && another.colors == colors && another.locations == locations
            && another.start == start && another.end == end && another.dimmedColors == dimmedColors
            && another.automaticallyDims == automaticallyDims && another.size == size
    }
    
    public override var hash: Int {
        var value = mode.hashValue
        value ^= NSValue(cgPoint: start).hashValue
        value ^= NSValue(cgPoint: end).hashValue
        value ^= NSNumber(value: automaticallyDims).hashValue
        value ^= NSValue(cgSize: size).hashValue
        if let colors = colors {
            value ^= colors.hashValue
        }
        if let locations = locations {
            value ^= locations.hashValue
        }
        if let colors = dimmedColors {
            value ^= colors.hashValue
        }
        return value
    }
}

public extension UIColor {
    static let defaultCache: NSCache<EZGradientOption, UIColor> = {
        let cache = NSCache<EZGradientOption, UIColor>()
        cache.name = "com.daubertjiang.ezgradient.cache"
        return cache
    }()
    
    static func gradientColor(with option: EZGradientOption,
                              cache: NSCache<EZGradientOption, UIColor>? = UIColor.defaultCache) -> UIColor? {
        let isDimmed = option.associatedView?.tintAdjustmentMode == .dimmed
        guard option.size.width > 0, option.size.height > 0, // 宽高不得为0
            let option = option.copy() as? EZGradientOption else {
                return nil
        }
        var color = cache?.object(forKey: option)
        guard color == nil else {
            return color?.copy() as? UIColor
        }
        var gradientImg: UIImage?
        guard let gradient = option.asCGGradient(isDimmed: isDimmed) else {
            return nil
        }
        UIGraphicsBeginImageContext(option.size)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }
        option.drawGradient(ctx, glossGradient: gradient)
        gradientImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let img = gradientImg else {
            return nil
        }
        color = UIColor(patternImage: img)
        if let color = color {
            cache?.setObject(color, forKey: option)
        }
        return color?.copy() as? UIColor
    }
}

@objc
@objcMembers public class EGGradientBackgroundOption: EZGradientOption {
    override func updateGradient() {
        guard canUpdate else {
            return
        }
        associatedView?.backgroundColor = asColor()
    }
}

@objc
@objcMembers public class EZGradientBorderOption: EZGradientOption {
    override func updateGradient() {
        guard canUpdate else {
            return
        }
        associatedView?.layer.borderColor = asColor()?.cgColor
    }
}

@objc
@objcMembers public class EZTextGradientOption: EZGradientOption {
    /// 文本观察者
    var textObserver: NSKeyValueObservation?
    /// 字体观察者
    var fontObserver: NSKeyValueObservation?
    //    override func observeView(_ view: UIView) {
    //        super.observeView(view)
    //        switch view {
    //        case let label as UILabel: setObserverForLabel(label)
    //        case let textView as UITextView: setObserverForTextView(textView)
    //        case let textField as UITextField: setObserverForTextField(textField)
    //        default: break
    //        }
    //    }
    
    func setObserverForLabel(_ label: UILabel) {
        textObserver = label.observe(\UILabel.text, changeHandler: { view, value in
            
        })
        
        fontObserver = label.observe(\UILabel.font, changeHandler: { view, value in
            
        })
    }
    
    func setObserverForTextView(_ textView: UITextView) {
        textObserver = textView.observe(\UITextView.text, changeHandler: { view, value in
            
        })
        
        fontObserver = textView.observe(\UITextView.font, changeHandler: { view, value in
            
        })
    }
    
    func setObserverForTextField(_ textField: UITextField) {
        textObserver = textField.observe(\UITextField.text, changeHandler: { view, value in
            
        })
        
        fontObserver = textField.observe(\UITextField.font, changeHandler: { view, value in
            
        })
    }
    
    func updateGradientColor(text: String, font: UIFont) {
        
    }
}
