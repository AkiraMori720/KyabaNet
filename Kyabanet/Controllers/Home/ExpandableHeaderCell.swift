//
//  ExpandableHeaderCell.swift
//  Life
//
//  Created by XianHuang on 6/26/20.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit

protocol CollapsibleTableViewHeaderDelegate {
    func toggleSection(_ header: ExpandableHeaderCell, section: Int)
}

class ExpandableHeaderCell: UITableViewHeaderFooterView {

    var delegate: CollapsibleTableViewHeaderDelegate?
    var section: Int = 0
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var arrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ExpandableHeaderCell.tapHeader(_:))))
    }
    
    @objc func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? ExpandableHeaderCell else {
            return
        }
        delegate?.toggleSection(self, section: cell.section)
    }
    
    func setCollapsed(collapsed: Bool){
        if(collapsed){
            arrowImageView.image = UIImage(systemName: "chevron.up")
        }
        else{
            arrowImageView.image = UIImage(systemName: "chevron.down")
        }
    }
    class func GetReuseIdentifier() -> String {
        return "expandableHeaderCell"
    }
        
    class func GetCellNib() -> UINib {
        let aNib = UINib.init(nibName: "ExpandableHeaderCell",bundle: Bundle.main);
        return aNib
    }
    
    class func RegisterAsAHeader(withTableView tableView:UITableView) {
        tableView.register(self.GetCellNib(), forHeaderFooterViewReuseIdentifier: self.GetReuseIdentifier())
    }
}
