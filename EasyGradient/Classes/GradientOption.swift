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
    public var colors: [UIColor]? {
        didSet {
            updateGradient()
        }
    }
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
    weak var _associatedView: UIView?
    /// 关联变化的视图
    public weak var associatedView: UIView? {
        set {
            defer {
                size = newValue?.frame.size ?? .zero
            }
            if _associatedView == newValue {
                return
            }
            _associatedView = newValue
            observer = _associatedView?.observe(\UIView.frame, changeHandler: { [weak self] view, value in
                guard let self = self else {
                    return
                }
                self.size = view.frame.size
            })
        }
        get {
            _associatedView
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
    
    required public override init() {
        super.init()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let option = type(of: self).init()
        option.canUpdate = false
        option.colors = colors
        option.dimmedColors = dimmedColors
        option.size = size
        option.drawOptions = drawOptions
        option.locations = locations
        option.start = start
        option.end = end
        option.mode = mode
        option.automaticallyDims = automaticallyDims
        option._associatedView = _associatedView
        option.canUpdate = true
        return option
    }
    
    func updateGradient() {}
    
    func gradientColors() -> [UIColor]? {
        if  associatedView?.tintAdjustmentMode == .dimmed {
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
    
    public func asCGGradient() -> CGGradient? {
        guard let colors = gradientColors() else {
            return nil
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorSpaceModel = colorSpace.model
        let gradientColors = colors.map { (color: UIColor) -> CGColor in
            let cgColor = color.cgColor
            let cgColorSpace = cgColor.colorSpace ?? colorSpace
            // The color's color space is RGB, simply add it.
            if cgColorSpace.model == colorSpaceModel {
                return cgColor
            }
            // Convert to RGB. There may be a more efficient way to do this.
            var red: CGFloat = 0
            var blue: CGFloat = 0
            var green: CGFloat = 0
            var alpha: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor
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
    
    public func asGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = gradientColors()?.map { $0.cgColor }
        layer.locations = locations?.map { $0 as NSNumber }.filter { !$0.isEqual(to: NSDecimalNumber.notANumber) } // 过滤掉NaN
        layer.endPoint = end
        layer.startPoint = start
        layer.type = mode.asGradientLayerType()
        layer.frame = CGRect(origin: .zero, size: size)
        return layer
    }
    
    public func asImage() -> UIImage? {
        guard let gradient = asCGGradient() else {
            return nil
        }
        var gradientImg: UIImage?
        UIGraphicsBeginImageContext(size)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }
        drawGradient(ctx, glossGradient: gradient)
        gradientImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return gradientImg
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
            && another.associatedView == associatedView
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
        if let view = associatedView {
            value ^= view.hashValue
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
        guard option.size.width > 0, option.size.height > 0, // 宽高不得为0
            let option = option.copy() as? EZGradientOption else {
                return nil
        }
        var color = cache?.object(forKey: option)
        guard color == nil else {
            return color?.copy() as? UIColor
        }
        guard let img = option.asImage() else {
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
        // Hack for UIlabel for weired space
        if let label = associatedView as? UILabel, label.text == nil {
            label.text = ""
        }
        associatedView?.backgroundColor = asColor()
    }
}

@objc
@objcMembers public class EZGradientBorderOption: EZGradientOption {
    /// 上边颜色
    public var topBorderColor: UIColor? {
        didSet {
            updateGradient()
        }
    }
    /// 右边颜色
    public var rightBorderColor: UIColor? {
        didSet {
            updateGradient()
        }
    }
    ///  底边颜色
    public var bottomBorderColor: UIColor? {
        didSet {
            updateGradient()
        }
    }
    /// 左边颜色
    public var leftBorderColor: UIColor? {
        didSet {
            updateGradient()
        }
    }
    
    /// 四个边是否分别设置颜色，默认为false，统一设置为渐变色
    public var useSeparateColor = false {
        didSet {
            updateGradient()
        }
    }
    
    public var drawsThinBorders: Bool = true {
        didSet {
            updateGradient()
        }
    }
    /// borderWith 观察者
    var borderWidthObserver: NSKeyValueObservation?
    
    var borderWidth: CGFloat = 0 {
        didSet {
            updateGradient()
        }
    }
    
    public override var associatedView: UIView? {
        didSet {
            /// 观察
            borderWidthObserver = associatedView?.observe(\UIView.layer.borderWidth,
                                                          changeHandler: { [weak self] view, value in
                                                            guard let self = self else {
                                                                return
                                                            }
                                                            let screen = view.window?.screen ?? UIScreen.main
                                                            var width = view.layer.borderWidth
                                                            if width <= 0 {
                                                                width = self.drawsThinBorders ? 1.0 / screen.scale : 1.0
                                                            }
                                                            self.borderWidth = width
            })
            let screen = associatedView?.window?.screen ?? UIScreen.main
            borderWidth = associatedView?.layer.borderWidth ?? (drawsThinBorders ? 1.0 / screen.scale : 1.0)
        }
    }
    
    override func gradientColors() -> [UIColor]? {
        guard useSeparateColor else {
            return super.gradientColors()
        }
        return [topBorderColor, leftBorderColor, bottomBorderColor, rightBorderColor].compactMap { $0 }
    }
    
    public override func asImage() -> UIImage? {
        guard useSeparateColor else {
            return super.asImage()
        }
        UIGraphicsBeginImageContext(size)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }
        var gradientImg: UIImage?
        // Top border
        if let color = topBorderColor {
            ctx.setFillColor(color.cgColor)
            ctx.fill(CGRect(origin: .zero, size: .init(width: size.width, height: borderWidth)))
        }
        let sideY: CGFloat = topBorderColor != nil ? borderWidth : 0
        let sideHeight = size.height - sideY - (bottomBorderColor != nil ? borderWidth : 0)
        // Right border
        if let color = rightBorderColor {
            ctx.setFillColor(color.cgColor)
            ctx.fill(CGRect(x: size.width - borderWidth, y: sideY, width: borderWidth, height: sideHeight))
        }
        // Bottom border
        if let color = bottomBorderColor {
            ctx.setFillColor(color.cgColor)
            ctx.fill(CGRect(x: 0, y: size.height - borderWidth, width: size.width, height: borderWidth))
        }
        // Left border
        if let color = leftBorderColor {
            ctx.setFillColor(color.cgColor)
            ctx.fill(CGRect(x: 0, y: sideY, width: borderWidth, height: sideHeight))
        }
        gradientImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return gradientImg
    }
    
    override func updateGradient() {
        guard canUpdate else {
            return
        }
        associatedView?.layer.borderColor = asColor()?.cgColor
    }
    
    public override func copy(with zone: NSZone? = nil) -> Any {
        let obj = super.copy(with: zone) as! EZGradientBorderOption
        obj.canUpdate = false
        obj.topBorderColor = topBorderColor
        obj.rightBorderColor = rightBorderColor
        obj.leftBorderColor = leftBorderColor
        obj.bottomBorderColor = bottomBorderColor
        obj.drawsThinBorders = drawsThinBorders
        obj.useSeparateColor = useSeparateColor
        obj.borderWidth = borderWidth
        obj.canUpdate = true
        return obj
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        let ret = super.isEqual(object)
        guard let another = object as? EZGradientBorderOption else {
            return false
        }
        return ret && self.borderWidth == another.borderWidth
    }
    
    public override var hash: Int {
        var value = super.hash
        value ^= (borderWidth as NSNumber).hashValue
        return value
    }
}

@objc
@objcMembers public class EZTextGradientOption: EZGradientOption {
    /// 文本观察者
    var textObserver: NSKeyValueObservation?
    /// 字体观察者
    var fontObserver: NSKeyValueObservation?
    
    public override var associatedView: UIView? {
        didSet {
            guard let view = associatedView else {
                return
            }
            switch view {
            case let label as UILabel: setObserverForLabel(label)
            case let textView as UITextView: setObserverForTextView(textView)
            case let textField as UITextField: setObserverForTextField(textField)
            default: break
            }
        }
    }
    
    /// 真实文字size
    fileprivate var _internalSize: CGSize = .zero {
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
    
    public override var size: CGSize {
        set {
            guard let view = associatedView else {
                _internalSize = newValue
                return
            }
            switch view { // 根据 View 类型调整真实 size
            case let label as UILabel:
                _internalSize = label.intrinsicContentSize
            case let textView as UITextView:
                updateSize(in: textView)
            case let textField as UITextField:
                _internalSize = textField.intrinsicContentSize
            default:
                _internalSize = newValue
            }
        }
        get {
            _internalSize
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func updateGradient() {
        guard canUpdate else {
            return
        }
        associatedView?.setValue(asColor(), forKey: "textColor")
    }
}
// MARK: - 处理 UITextField
extension EZTextGradientOption {
    func setObserverForTextField(_ textField: UITextField) {
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        fontObserver = textField.observe(\UITextField.font, changeHandler: { [weak self] view, value in
            self?._internalSize = view.intrinsicContentSize
        })
        _internalSize = textField.intrinsicContentSize
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        _internalSize = textField.intrinsicContentSize
    }
}
// MARK: - 处理 UILabel
extension EZTextGradientOption {
    func setObserverForLabel(_ label: UILabel) {
        textObserver = label.observe(\UILabel.text, changeHandler: { [weak self] view, value in
            self?._internalSize = view.intrinsicContentSize
        })
        fontObserver = label.observe(\UILabel.font, changeHandler: { [weak self] view, value in
            self?._internalSize = view.intrinsicContentSize
        })
        _internalSize = label.intrinsicContentSize
        updateGradient()
    }
}
// MARK: - 处理 UITextView
extension EZTextGradientOption {
    func setObserverForTextView(_ textView: UITextView) {
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange(_:)),
                                               name: .UITextViewTextDidChange, object: nil)
        fontObserver = textView.observe(\UITextView.font, changeHandler: { [weak self] view, value in
            self?.updateSize(in: view)
        })
        updateSize(in: textView)
    }
    
    func textViewDidChange(_ notification: Notification) {
        guard let textView = notification.object as? UITextView, textView === associatedView else {
            return
        }
        updateSize(in: textView)
    }
    
    func updateSize(in textView: UITextView) {
        guard let str = textView.text, let font = textView.font else {
            return
        }
        // FIXME: A weird bug, the calculation of bouding rect seems not precise.
        let attrStr = NSAttributedString(string: str + " ", attributes: [ .font: font ])
        _internalSize = attrStr.boundingRect(with: textView.contentSize,
                                             options: .usesLineFragmentOrigin, context: nil).size
//        print(_internalSize)
    }
}

