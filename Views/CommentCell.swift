//
//  CommentCell.swift
//  Reddity
//
//  Created by Qiang Guo on 16/9/12.
//  Copyright © 2016年 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework

class CommentCell: BaseTableViewCell {

    @IBOutlet weak var leadingMarginConstraint: NSLayoutConstraint!
    
    lazy var comment: UILabel! = {
        return self.viewWithTag(1) as! UILabel
    }()
    
    /**
     The maximum level of a comment in the comment tree hierachy.
     
     @discussion Usually after five or six levels, user won't care to descend further. Therefore
     maximum number of 20 levels are more than enough.
     */
    let maxLevel: Int = 20
    
    /**
     Point on screen per level
     */
    let marginUnit: CGFloat = 5
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.applyTheme()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommentCell.applyTheme), name: kThemeManagerDidChangeThemeNotification, object: nil)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    /**
     Load the comment and set proper left margin
     */
    func loadComment(atLevel: Int, text: String) {
        var level = atLevel
        if level > self.maxLevel { level = self.maxLevel }
        
        self.leadingMarginConstraint.constant = CGFloat(level) * self.marginUnit
        self.comment.text = text
    }
    
    override func applyTheme() {
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.backgroundColor = FlatBlack()
            self.comment?.textColor = FlatWhite()
            
            let bg = UIView()
            bg.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
            self.selectedBackgroundView = bg
        } else {
            self.backgroundColor = UIColor.whiteColor()
            self.comment?.textColor = UIColor.blackColor()
            
            let bg = UIView()
            bg.backgroundColor = UIColor(colorLiteralRed: 252/255, green: 126/255, blue: 15/255, alpha: 0.05)
            self.selectedBackgroundView = bg
        }

    }
    
}
