//
//  PlaytimeLabel.swift
//  Reddity
//
//  Created by Qiang Guo on 2017/1/30.
//  Copyright © 2017年 Qiang Guo. All rights reserved.
//
import UIKit


protocol PlaytimeLabelProtocol {
    func updateText(for label: UILabel)
}


class PlaytimeLabel: UILabel {
    
    var displayLink: CADisplayLink!
    
    var delegate: PlaytimeLabelProtocol?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        
        self.textColor = UIColor.whiteColor()
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.75)
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
        self.textAlignment = .Center
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(PlaytimeLabel.updateText))
        self.displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    override func drawTextInRect(rect: CGRect) {
        let insets = UIEdgeInsetsMake(4, 5, 4, 5)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
    
    @objc func updateText() {
        if let delegate = delegate {
            delegate.updateText(for: self)
        }
    }
}
