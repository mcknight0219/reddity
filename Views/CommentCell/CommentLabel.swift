//
// Created by Qiang Guo on 16/9/23.
// Copyright (c) 2016 Qiang Guo. All rights reserved.
//

import UIKit
import SafariServices
import SwiftyMarkdown

protocol CommentLabelDelegate {
    func urlDidTapped(URL: NSURL)
}

/**
 The CommentLabel is customized to handle taps on url links. It displays
 the alert before switching to SafariViewController for websites.
 */
class CommentLabel : UILabel {
    
    var delegate: CommentLabelDelegate?
    
    var activeLink: NSURL?
    
    var unhighlighedAttributedText: NSAttributedString?
    
    override var text: String? {
        didSet {
            if let attributedText = self.parseMarkdown(text: self.text ?? "") {
                self.attributedText = attributedText
            }
        }
    }

    lazy var layoutManager: NSLayoutManager = {
        return NSLayoutManager()
    }()
    
    var textStorage: NSTextStorage?
    
    lazy var textContainer: NSTextContainer = {
        var container = NSTextContainer(size: self.bounds.size)
        
        container.lineBreakMode = self.lineBreakMode
        container.maximumNumberOfLines = self.numberOfLines
        container.lineFragmentPadding = 0
        
        return container
    }()

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    
    func commonInit() {
        self.isUserInteractionEnabled = true
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        self.textAlignment = .natural
    }
    
    
    fileprivate func characterIndex(atPoint point: CGPoint) -> Int {
        guard let _ = self.attributedText else {
            return NSNotFound
        }
        
        textStorage = NSTextStorage(attributedString: self.attributedText!)
        layoutManager.addTextContainer(textContainer)
        textStorage?.addLayoutManager(layoutManager)
        
        let coefficent: CGFloat = textAlignment == .center ? 0.5 : (textAlignment == .right ? 1.0 : 0.0)
        
        let boundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (self.bounds.size.width - boundingBox.size.width) * coefficent - boundingBox.origin.x,
                                          y: (self.bounds.size.height - boundingBox.size.height) * 0.5 - boundingBox.origin.y)
        let locationOfTouch = CGPoint(x: point.x - textContainerOffset.x, y: point.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouch, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return indexOfCharacter
    }
    
    private func applyHighlightAt(index: Int) {
        guard index != NSNotFound else {
            return
        }
        
        let attributedString = self.attributedText?.mutableCopy() as! NSMutableAttributedString
        self.unhighlighedAttributedText = attributedString
        
        var effectiveRange = NSMakeRange(0, 0)
        if let _ = attributedString.attribute(NSLinkAttributeName, at: index, longestEffectiveRange: &effectiveRange, in: NSMakeRange(0, attributedString.length)) {
            attributedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.lightGray, range: effectiveRange)
            self.attributedText = attributedString
            
            return
        }
        //removeHightlightAt(index)
    }
    
    private func removeHightlightAt(index: Int) {
        guard index != NSNotFound && self.unhighlighedAttributedText != nil else {
            return
        }
        
        self.attributedText = self.unhighlighedAttributedText
    }
}

// MARK:  User interaction

extension CommentLabel {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch  = touches.first!
        let characterIndex = self.characterIndex(atPoint: touch.location(in: self))
        if characterIndex == NSNotFound {
            super.touchesBegan(touches, with: event)
            return
        }
        
        //self.applyHighlightAt(characterIndex)
        
        let attributes = self.attributedText?.attributes(at: characterIndex, effectiveRange: nil)
        if let URL = attributes?[NSLinkAttributeName] as? NSURL {
            self.activeLink = URL
        } else {
            self.activeLink = nil
            super.touchesBegan(touches, with: event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let url = self.activeLink {
            
            self.delegate?.urlDidTapped(URL: url)
            
        } else {
            
            super.touchesEnded(touches, with: event)
        
        }
    }
}

// MARK: -- Markdown format support

extension CommentLabel {

    /**
     This function converts md text to NSAttributedText to display in label. 

     @discussion it supports bold, strikethrough, link and raw url. Also it supports
     item list
     */
    func parseMarkdown(text: String) -> NSAttributedString? {
        guard !text.isEmpty else {
            return nil
        }

        let md = SwiftyMarkdown(string: text)
        md.link.color = UIColor.blue
        md.code.fontName = "CourierNewPSMT"

        return md.attributedString()
    }
}
