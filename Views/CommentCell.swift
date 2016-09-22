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
    
    lazy var comment: UILabel! = {
        return self.viewWithTag(1) as! UILabel
    }()
    
    lazy var vote: UIImageView! = {
        return self.viewWithTag(2) as! UIImageView
    }()

    lazy var pointLabel: UILabel! = {
        return self.viewWithTag(3) as! UILabel
    }()

    lazy var userLabel: UILabel! = {
        return self.viewWithTag(4) as! UILabel
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
    func configCellWith(comment: Comment) {
        
        self.leadingMarginConstraint.constant = comment.level * self.marginUnit

        if self.comment.isPlaceholder {
            
            self.bottomSectHeightConstraint.constant = 0

            self.comment.text = "Load more"

            return
        }


        self.comment.text = comment.text
        self.pointLabel.text = String(comment.score)
        self.userLabel.text = comment.user
        
        self.vote.image = UIImage.fontAwesomeIconWithName(.ThumbsOUp, textColor: UIColor.grayColor(), size: CGSize(width: 17, height: 17))
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(CommentCell.voteIconClicked))
        singleTap.numberOfTapsRequired = 1
        self.vote.userInteractionEnabled = true
        self.vote.gestureRecognizers = [singleTap]
    }
    
    override func applyTheme() {
        super.applyTheme()
        
        if ThemeManager.defaultManager.currentTheme == "Dark" {
            self.comment?.textColor = FlatWhiteDark()
        } else {
            self.comment?.textColor = UIColor.blackColor()
        }
    }

    func voteIconClicked() {
        print("Vote clicked ")
    }
}


extension CommentCell {
    
    func transformMarkdown(text: String) -> NSAttributedString {
        
    }
}
