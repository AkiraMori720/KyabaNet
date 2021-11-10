//
//  SettingCell.swift
//  Life
//
//  Created by Yun Li on 2020/6/26.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import Foundation
import UIKit
class SettingCell : UITableViewCell{
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var profile: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
