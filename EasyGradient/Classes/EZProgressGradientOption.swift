//
//  ProgressGradientOption.swift
//  EasyGradient
//
//  Created by 姜振华 on 2020/4/20.
//

import Foundation
import UIKit

public class EZProgressGradientOption: EZGradientOption {
    
    var progressOB: NSKeyValueObservation?
    
    var _size: CGSize = .zero {
        didSet {
            updateGradient()
        }
    }
    
    public override var size: CGSize {
        set {
            _size = newValue
        }
        get {
            _size
        }
    }
    
    public override var associatedView: UIView? {
        didSet {
            guard let progressView = associatedView as? UIProgressView else {
                return super.updateGradient()
            }
            progressOB = progressView.observe(\UIProgressView.progress) { [weak self] view, value in
                guard let self = self else {
                    return
                }
                self.updateTrackSize(progressView: view)
            }
            updateTrackSize(progressView: progressView)
        }
    }
    
    func updateTrackSize(progressView: UIProgressView) {
        if fixedWidth {
            _size = progressView.frame.size
        } else {
            _size = CGSize(width: progressView.frame.width * CGFloat(progressView.progress),
                           height: progressView.frame.height)
        }
    }
    
    public var fixedWidth: Bool = true {
        didSet {
            updateGradient()
        }
    }
    
    override func updateGradient() {
        guard let progressView = associatedView as? UIProgressView else {
            return super.updateGradient()
        }
        progressView.progressImage = asImage()
    }
}
