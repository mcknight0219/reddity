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
        
        self.textColor = UIColor.white
        self.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
        self.textAlignment = .center
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(PlaytimeLabel.updateText))
        self.displayLink.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsetsMake(4, 5, 4, 5)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    @objc func updateText() {
        if let delegate = delegate {
            delegate.updateText(for: self)
        }
    }
}
