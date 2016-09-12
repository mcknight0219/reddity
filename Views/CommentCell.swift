//
//  CommentCell.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-09-12.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

class CommentCell: BaseTableViewCell {
    
    var content: UILabel

    /**
     The level of this comment in the comment tree
     */
    var level: Int

    /**
     The maximum level of replies that are supported.

     @discussion Usually any level above five or six becomes un-interesting to readers.
     Any comment that is under `maxLevelOfComment` will be discarded
     */
    let maxLevelOfComment = 10

    /**
     On-screen point per level
     */
    let leadingMarginUnit = 5
}

