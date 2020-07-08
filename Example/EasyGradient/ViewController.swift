//
//  ViewController.swift
//  EasyGradient
//
//  Created by AmatsuZero on 04/13/2020.
//  Copyright (c) 2020 AmatsuZero. All rights reserved.
//

import UIKit
import EasyGradient

class ViewController: UIViewController {
    @GradientWrapper(UILabel(frame: .init(origin: CGPoint(x: 10, y: 64), size: CGSize(width: 300, height: 100))),
                     option: EZTextGradientOption.testOption())
    var label: UILabel
    let textField = UITextField(frame: .init(origin: .init(x: 10, y: 174), size: .init(width: 300, height: 300)))
    let textView = UITextView(frame: .init(origin: .init(x: 10, y: 474), size: .init(width: 300, height: 200)))
    let progressView = UIProgressView(frame: .init(origin: .init(x: 10, y: 674), size: .init(width: 300, height: 10)))
    
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.label.frame.size.width = 200
            self.label.text = "Hello"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                 self.label.text = "H"
//                self.label.frame.size.width = 100
//                self.label.layer.borderWidth = 2
//                self.label.borderGradientOption?.useSeparateColor = false
//                self.label.borderGradientOption?.colors = [.cyan, .brown]
            }
        }
        label.textAlignment = .center
        label.text = "Hello world"
       
        let borderOption = EZGradientBorderOption()
        borderOption.topBorderColor = .magenta
        borderOption.leftBorderColor = .blue
        borderOption.rightBorderColor = .green
        borderOption.bottomBorderColor = .orange
        borderOption.useSeparateColor = true
        label.layer.borderWidth = 4
        label.borderGradientOption = borderOption

        view.addSubview(textField)
        textField.text = "Test"
        let textOption = EZTextGradientOption()
        textOption.direction = .leftToRight
        textOption.colors = [.red, .yellow]
        textField.textGradientOption = textOption
        textField.backgroundColor = .darkGray
        
        view.addSubview(textView)
        textView.backgroundColor = .gray
        textView.font = UIFont.systemFont(ofSize: 16)
        let textOption2 = EZTextGradientOption()
        textOption2.direction = .leftToRight
        textOption2.colors = [.red, .yellow]
        textView.textGradientOption = textOption2
        progressView.backgroundColor = .red
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 9)
        view.addSubview(progressView)
        let progressOption = EZProgressGradientOption()
        progressOption.colors = [.red, .yellow]
        progressOption.direction = .leftToRight
        progressView.progressGradientOption = progressOption
        
        timer = Timer(timeInterval: 1, target: self, selector: #selector(updateProgress(_:)), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .commonModes)
    }
    
    @objc func updateProgress(_ timer: Timer) {
        progressView.progress += 0.1
        if progressView.progress >= 1 {
            timer.invalidate()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension EZTextGradientOption {
    static func testOption() -> EZTextGradientOption {
        let textOptionA = EZTextGradientOption()
        textOptionA.direction = .leftToRight
        textOptionA.colors = [.red, .yellow]
        return textOptionA
    }
}
