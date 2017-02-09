//
//  String+Reddity.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-25.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import CoreText

let urlPattern = try! NSRegularExpression(pattern: "^(https?|ftp|file)://.+$", options: .CaseInsensitive)
let imgurPattern = try! NSRegularExpression(pattern: "^.+(imgur.com)/[0-9a-zA-Z]+/?$", options: .CaseInsensitive)

extension String {
    func startsWith(sub: String) -> Bool {
        guard self.characters.count >= sub.characters.count else {
            return false
        }
        
        return self.characters.prefix(sub.characters.count).elementsEqual(sub.characters)
    }
    
    func heightWithContrained(width: CGFloat, font: UIFont) -> CGFloat {
        let maxRect = CGSize(width: width, height: CGFloat.max)
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .ByWordWrapping
        let boundingBox = self.boundingRectWithSize(maxRect, options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: [NSFontAttributeName: font, NSParagraphStyleAttributeName: style], context: nil)
    
        return boundingBox.height
    }

    func breaksIntoLines(constrained rect: CGRect, font: UIFont) -> [String] {
        let ctFont: CTFontRef = CTFontCreateWithName(font.fontName, font.pointSize, nil)
        let attributedStr = NSMutableAttributedString(string: self)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 0
        attributedStr.addAttributes([NSParagraphStyleAttributeName: style, NSFontAttributeName: font], range: NSRange(location: 0, length: attributedStr.length))
        let frameSetter: CTFramesetterRef = CTFramesetterCreateWithAttributedString(attributedStr as CFAttributedStringRef)
        let path: CGMutablePathRef = CGPathCreateMutable()
        CGPathAddRect(path, nil, rect)
        let frame: CTFrameRef = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        let lines = CTFrameGetLines(frame) as NSArray

        var res = [String]()
        for line in lines {
           let lineRange = CTLineGetStringRange(line as! CTLine)
           let range: NSRange = NSRange(location: lineRange.location, length: lineRange.length)
           res.append((self as NSString).substringWithRange(range) as String)
        }

        return res
    }
}

extension String {

    func test(pattern: String) -> Bool {
        guard !isEmpty && !pattern.isEmpty else {
            return false
        }

        return rangeOfString(pattern, options: .RegularExpressionSearch) != nil
    }
}
