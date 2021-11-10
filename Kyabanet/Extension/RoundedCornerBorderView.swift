//
//  RoundedCornerBorderView.swift
//  Life
//
//  Created by Yun Li on 2020/7/2.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RoundedCornerBorderView: UIView {
    
    // if cornerRadius variable is set/changed, change the corner radius of the UIView
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
}

