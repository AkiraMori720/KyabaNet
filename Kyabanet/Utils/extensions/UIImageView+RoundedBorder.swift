//
//  UIImageView+RoundedBorder.swift
//  WORX
//
//  Created by Jaelhorton on 5/23/20.
//  Copyright © 2020 worx. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {

    func makeRounded() {

        self.layer.borderWidth = 2
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
    
}
