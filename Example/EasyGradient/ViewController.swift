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
    
    var label = UILabel(frame: .init(origin: CGPoint(x: 10, y: 64), size: CGSize(width: 300, height: 100)))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.label.frame.size.width = 200
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.label.frame.size.width = 100
                self.label.layer.borderWidth = 2
                self.label.borderGradientOption?.useSeparateColor = false
                self.label.borderGradientOption?.colors = [.cyan, .brown]
            }
        }
        let option = EGGradientBackgroundOption()
        option.direction = .leftToRight
        option.locations = [0,1]
        option.colors = [.red, .yellow]
        label.bgGradientOption = option
       
        let borderOption = EZGradientBorderOption()
        borderOption.topBorderColor = .magenta
        borderOption.leftBorderColor = .blue
        borderOption.rightBorderColor = .green
        borderOption.bottomBorderColor = .orange
        borderOption.useSeparateColor = true
        label.layer.borderWidth = 4
        label.borderGradientOption = borderOption

        label.textAlignment = .center
        label.text = "Hello world"
        let textOption = EZTextGradientOption()
        textOption.direction = .topToBottom
        textOption.colors = [.purple, .brown]
        label.textGradientOption = textOption
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

