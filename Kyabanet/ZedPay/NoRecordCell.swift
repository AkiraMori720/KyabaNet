//
//  NoRecordCell.swift
//  Life
//
//  Created by mac on 2021/6/20.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit

class NoRecordCell: UITableViewCell {

    @IBOutlet weak var labelRecord: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        labelRecord.text = "No Records".localized
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
