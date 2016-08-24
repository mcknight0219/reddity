//
//  TagList.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-24.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

struct TagAppearance {
    let foregroundColor: UIColor?
    let backgroundColor: UIColor?
    let borderWidth: Int?
    let borderRadius: Int?
}

/**
 This view shows a list of tags that user could click to trigger actions

 @discussion The tags are displayed in the order they are added.
 */
class TagList: UIView {
    /**
     The list of buttons user could click
     */
    var tags = [UIButton]()

    /**
     An array of width corresponding to tags
     */
    var tagsWidth = [Int]()

    /**
     The spacing between two rows of tags.
     */
    let rowPadding: Int = 5

    /**
     The spacing between two tags.
     */
    let tagPadding: Int = 3

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func addTag(tag: UIButton?) {
        // Don't add already existing tags
        guard (self.tags.filter { $0 == tag }).count == 0 else { return }
        self.tags.append(tag)

        // Calculate the width of the button
        let width = tag.currentTitle.sizeWithAttributes([NSFontAttributeName: tag.titleLabel?.font]).width + tag.contentEdgeInsects.left + tag.contentEdgeInsects.right + tag.layer.borderWidth * 2
        self.tagsWidth.append(width)
        addSubview(tag)
    }

    func addTagTitle(title: String, action: (UIButton) -> Void, appearance: TagAppearance?) {
        let tag =                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              UIButton(type: Custom)
        tag.setTitle(title, forState: .Normal)
        tag.addTarget(nil, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        if let appearance = appearance {
            tag.tintColor = appearance.foregroundColor ?? FlatOrangeDark()
            tag.backgroundColor = appearance.backgroundColor ?? UIColor.clearColor()
            tag.layer.borderWidth = appearance.borderWidth ?? 1 
            tag.layer.borderRadius = appearance.borderRadiu ?? 3
        } else {
            tag.tintColor = FlatOrangeDark()
            tag.backgroundColor = UIColor.clearColor()
            tag.layer.borderWidth = 1
            tag.layer.borderRadius = 3
        }
        
        self.tagTag(tag)
    }

    /**
     Layout the subiew according to widths calculated in `tagsWidth`

     @discussion 
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        guard self.tags.count > 0 { return }
        
        let maxW = frame.width
        let maxH - frame.heigth
        var l = 0 // The current line
        var i = 0 // the index of current tag
        var w = 0 // the cumulative width of current line 
        while i < tags.count {
            if w < maxW - 25 {
                tags[i].origin = CGPointMake(w + tagPadding, l * 40)
                w += tagsWidth[i]
            } else {
                l += 1
                w = 0
            }
            i += 1
        }
    }
}

extension UIView {
    func origin() -> CGPoint {
        return frame.origin
    }

    func setOrigin(origin: CGPoint) {
        var oldFrame = frame
        self.frame = CGRectMake(origin.x, origin.y, frame.width, frame.height) 
    } 
}
