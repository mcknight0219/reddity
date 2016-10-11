//
//  LoadmoreCell.swift
//  Reddity
//
//  Created by Qiang Guo on 16/10/7.
//  Copyright © 2016年 Qiang Guo. All rights reserved.
//

import UIKit

class LoadmoreCell: BaseTableViewCell {
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    lazy var content: UILabel! = {
        return self.viewWithTag(1) as! UILabel
    }()
    
    lazy var img: UIImageView! = {
        return self.viewWithTag(2) as! UIImageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyTheme()
    }
    
    func configWith(inout aComment: Comment) {
        var aComment = aComment
        self.leadingConstraint.constant = CGFloat(aComment.level) * 15
        self.content.text = "Load more"
        self.content.font = UIFont(name: "Lato-Regular", size: 16)!
        self.content.sizeToFit()
        
        img.image = UIImage.fontAwesomeIconWithName(.CaretDown, textColor: UIColor.blueColor(), size: CGSize(width: 16, height: 16))
        img.contentMode = .ScaleAspectFill
    }
    
    override func applyTheme() {
        super.applyTheme()
        content.textColor = UIColor.blueColor()
    }

}
