//
//  RoundButton.swift
//  JackTag
//
//  Created by Xian Huang on 1/26/20.
//  Copyright © 2020 Xian Huang. All rights reserved.
//
import UIKit

@IBDesignable class RoundButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func refreshCorners(value: CGFloat) {
        layer.cornerRadius = value
    }
    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet {
            refreshCorners(value: cornerRadius)
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.white {
       didSet {
           layer.borderColor = borderColor.cgColor
       }
    }

    @IBInspectable var borderWidth: CGFloat = 2.0 {
       didSet {
           layer.borderWidth = borderWidth
       }
    }
    func sharedInit() {
        refreshCorners(value: cornerRadius)

    }
}
