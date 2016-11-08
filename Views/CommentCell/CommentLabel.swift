//
// Created by Qiang Guo on 16/9/23.
// Copyright (c) 2016 Qiang Guo. All rights reserved.
//

import UIKit
import SafariServices


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
            if let attributedText = self.parseMarkdown(self.text ?? "") {
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
        self.userInteractionEnabled = true
        self.numberOfLines = 0
        self.lineBreakMode = .ByWordWrapping
        self.textAlignment = .Natural
    }
    
    
    private func characterIndex(atPoint point: CGPoint) -> Int {
        guard let _ = self.attributedText else {
            return NSNotFound
        }
        
        textStorage = NSTextStorage(attributedString: self.attributedText!)
        layoutManager.addTextContainer(textContainer)
        textStorage?.addLayoutManager(layoutManager)
        
        let coefficent: CGFloat = textAlignment == .Center ? 0.5 : (textAlignment == .Right ? 1.0 : 0.0)
        
        let boundingBox = layoutManager.usedRectForTextContainer(textContainer)
        let textContainerOffset = CGPointMake((self.bounds.size.width - boundingBox.size.width) * coefficent - boundingBox.origin.x,
                                              (self.bounds.size.height - boundingBox.size.height) * 0.5 - boundingBox.origin.y)
        let locationOfTouch = CGPointMake(point.x - textContainerOffset.x, point.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndexForPoint(locationOfTouch, inTextContainer: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return indexOfCharacter
    }
    
    private func applyHighlightAt(index: Int) {
        guard index != NSNotFound else {
            return
        }
        
        let attributedString = self.attributedText?.mutableCopy() as! NSMutableAttributedString
        self.unhighlighedAttributedText = attributedString
        
        var effectiveRange = NSMakeRange(0, 0)
        if let _ = attributedString.attribute(NSLinkAttributeName, atIndex: index, longestEffectiveRange: &effectiveRange, inRange: NSMakeRange(0, attributedString.length)) {
            
            attributedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.lightGrayColor(), range: effectiveRange)
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
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch  = touches.first!
        let characterIndex = self.characterIndex(atPoint: touch.locationInView(self))
        if characterIndex == NSNotFound {
            super.touchesBegan(touches, withEvent: event)
            return
        }
        
        //self.applyHighlightAt(characterIndex)
        
        let attributes = self.attributedText?.attributesAtIndex(characterIndex, effectiveRange: nil)
        if let URL = attributes?[NSLinkAttributeName] as? NSURL {
            self.activeLink = URL
        } else {
            self.activeLink = nil
            super.touchesBegan(touches, withEvent: event)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let url = self.activeLink {
            
            self.delegate?.urlDidTapped(url)
            
        } else {
            
            super.touchesEnded(touches, withEvent: event)
        
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

        // Start a chain of parsing and replacing Markdown grammars
        return NSMutableAttributedString(string: text).replaceOccurrence(ofPattern: "\\*.+\\*") { (r, ms) -> NSAttributedString in
            let b = UIFont(name: "Lato-Bold", size: 15)!
            let s = NSString(string: ms.string)
            return NSAttributedString(string: s.substringWithRange(r.shrinkBy(1)), attributes: [NSFontAttributeName: b])
            }
            .replaceOccurrence(ofPattern: "~~.+~~") { (r, ms) -> NSAttributedString in
                let s = NSString(string: ms.string)
                return NSAttributedString(string: s.substringWithRange(r.shrinkBy(2)), attributes: [NSStrikethroughStyleAttributeName: NSNumber(integer: NSUnderlineStyle.StyleThick.rawValue)])
            }
            .replaceOccurrence(ofPattern: "\\[.+\\]\\((https?|ftp|file)://\\S+\\)") { (r, ms) -> NSAttributedString in
                let s = NSString(string: ms.string).substringWithRange(r)
                var t = NSMakeRange(1, 0)
                for (i, c) in s.characters.enumerate() {
                    if c == "]" {
                        t.length = i - 1
                        break
                    }
                }
                let ns = s as NSString
                let url = NSURL(string: ns.substringWithRange(NSMakeRange(t.location+t.length+2, ns.length-t.location-t.length-3)))!
                return NSAttributedString(string: ns.substringWithRange(t), attributes: [NSLinkAttributeName: url])
            }
            .replaceOccurrence(ofPattern: Config.URLPattern) { (r, ms) -> NSAttributedString in
                let s = NSString(string: ms.string)
       
                if let url = NSURL(string: s.substringWithRange(r)) {
                    return NSAttributedString(string: url.host!, attributes: [NSLinkAttributeName: url])
                } else {
                    return NSAttributedString(string: s.substringWithRange(r))
                }
            }
            .replaceOccurrence(ofPattern: "([ \\t]?-\\s\\S.+\\n?)+") { (r, ms) -> NSAttributedString in
                let s = NSString(string: ms.string).substringWithRange(r) as NSString
                // The item lists
                let p = NSMutableParagraphStyle()
                p.firstLineHeadIndent = 10
                p.paragraphSpacing = 4
                p.paragraphSpacingBefore = 3
                p.lineBreakMode = .ByWordWrapping
                
                return NSAttributedString(string: s as String, attributes: [NSParagraphStyleAttributeName: p])
            }
        
    }
}
