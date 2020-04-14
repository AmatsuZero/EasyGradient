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
    
    var label: UILabel? = UILabel(frame: .init(origin: CGPoint(x: 0, y: 64), size: CGSize(width: 100, height: 100)))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.label?.frame.size.width = 200
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.label?.frame.size.width = 100
            }
        }
        let option = EGGradientBackgroundOption(beginColor: .red, endColor: .yellow, size: label!.frame.size)
        label?.bgGradientOption = option
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

