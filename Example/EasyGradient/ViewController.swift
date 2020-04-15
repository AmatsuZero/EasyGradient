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
    
    var label = UIView(frame: .init(origin: CGPoint(x: 0, y: 64), size: CGSize(width: 300, height: 100)))

    override func viewDidLoad() {
        super.viewDidLoad()
        print(view.layoutMargins.right)
        view.addSubview(label)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.label.frame.size.width = 200
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.label.frame.size.width = 100
            }
        }
        let option = EGGradientBackgroundOption()
        option.size = label.frame.size
        option.direction = .leftToRight
        option.locations = [0,1]
        option.colors = [.red, .yellow]
        label.bgGradientOption = option
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

