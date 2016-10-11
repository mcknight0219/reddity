//
//  CommentCell.swift
//  Reddity
//
//  Created by Qiang Guo on 16/9/12.
//  Copyright © 2016年 Qiang Guo. All rights reserved.
//

import UIKit
import ChameleonFramework
import FontAwesome_swift

class CommentCell: BaseTableViewCell {

    @IBOutlet weak var leadingMarginConstraint: NSLayoutConstraint!

    @IBOutlet weak var bottomSectHeightConstraint: NSLayoutConstraint!
    
    lazy var commentLabel: CommentLabel! = {
        return self.viewWithTag(1) as! CommentLabel
    }()

    lazy var infoLabel: UILabel! = {
        return self.viewWithTag(3) as! UILabel
    }()
    
    lazy var userLabel: UILabel! = {
        return self.viewWithTag(2) as! UILabel
    }()
    
    lazy var up: UIImageView! = {
       return self.viewWithTag(4) as! UIImageView
    }()
    
    lazy var down: UIImageView! = {
        return self.viewWithTag(5) as! UIImageView
    }()

    lazy var score: UILabel! = {
        return self.viewWithTag(6) as! UILabel
    }()
    
    var comment: Comment!

    /**
     The maximum level of a comment in the comment tree hierachy.
     
     @discussion Usually after five or six levels, user won't care to descend further. Therefore
     maximum number of 20 levels are more than enough.
     */
    let maxLevel: Int = 20
    
    /**
     Point on screen per level
     */
    let marginUnit: CGFloat = 15
    
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
    func configCellWith(inout aComment: Comment) {
        self.comment = aComment
        self.leadingMarginConstraint.constant = CGFloat(self.comment.level) * self.marginUnit
        self.separatorInset = UIEdgeInsetsMake(0, self.leadingMarginConstraint.constant - 10, 0, 0)

        commentLabel.text = aComment.text
        infoLabel.attributedText = NSMutableAttributedString(string: "・Reply・\(NSDate.describePastTimeInDays(aComment.createdAt))", attributes: [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 15)!])
        userLabel.text = aComment.user
        score.text = "\(aComment.score)"
        up.image = UIImage.fontAwesomeIconWithName(.ArrowUp, textColor: FlatGreenDark(), size: CGSizeMake(15, 15))
        down.image = UIImage.fontAwesomeIconWithName(.ArrowDown, textColor: FlatRedDark(), size: CGSizeMake(15, 15))
    }
    
    override func applyTheme() {
        super.applyTheme()
        
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.commentLabel?.textColor = UIColor(colorLiteralRed: 113/255, green: 115/255, blue: 130/255, alpha: 1.0)
        } else {
            self.commentLabel?.textColor = UIColor.blackColor()
        }

        self.commentLabel?.font = UIFont(name: "Lato-Regular", size: 18)
    }

    func voteIconClicked() {
        print("Vote clicked ")
    }
}
