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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
        
        removeHightlightAt(index)
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
        
        self.applyHighlightAt(characterIndex)
        
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
    func parseMarkdown(text: String) -> NSAttributedString? {
        guard text.isEmpty else {
            return nil
        }

        var ms = NSMutableAttributedString(string: text)

        // Bold texts
        if let matches = ms.string.matchesAll("*.+*") {
            matches.forEach { range in
                let boldFont = UIFont(name: "Lato-Bold", size: 12)!
                let boldStr = NSAttributedString(string: ms.string.substring(with: range), attributes: [NSFontAttributeName: boldFont])
                ms.replaceCharactersInRange(range, withAttributedString: boldStr)
            }
        }

        // Strike-through text
        if let matches = ms.string.matchesAll("~~.+~~") {
            
        }

        // Link text
        if let matches = ms.string.matchesAll("") {
            
        }

        // Any remaining url link
        if let matches = ms.string.matchesAll(Config.URLPattern) {
            
        }

        return ms
    }
}
