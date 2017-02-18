//
//  String+Reddity.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-25.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import CoreText

let urlPattern = try! NSRegularExpression(pattern: "^(https?|ftp|file)://.+$", options: .caseInsensitive)
let imgurPattern = try! NSRegularExpression(pattern: "^.+(imgur.com)/[0-9a-zA-Z]+/?$", options: .caseInsensitive)

extension String {
    func startsWith(sub: String) -> Bool {
        guard self.characters.count >= sub.characters.count else {
            return false
        }
        
        return self.characters.prefix(sub.characters.count).elementsEqual(sub.characters)
    }
    
    func heightWithContrained(width: CGFloat, font: UIFont) -> CGFloat {
        let maxRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        let boundingBox = self.boundingRect(with: maxRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: font, NSParagraphStyleAttributeName: style], context: nil)
    
        return boundingBox.height
    }

    func breaksIntoLines(constrained rect: CGRect, font: UIFont) -> [String] {
        // let ctFont: CTFont = CTFontCreateWithName(font.fontName as CFString?, font.pointSize, nil)
        let attributedStr = NSMutableAttributedString(string: self)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 0
        attributedStr.addAttributes([NSParagraphStyleAttributeName: style, NSFontAttributeName: font], range: NSRange(location: 0, length: attributedStr.length))
        let frameSetter: CTFramesetter = CTFramesetterCreateWithAttributedString(attributedStr as CFAttributedString)
        let path: CGMutablePath = CGMutablePath()
        
        path.addRect(rect)
        let frame: CTFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        let lines = CTFrameGetLines(frame) as NSArray

        var res = [String]()
        for line in lines {
           let lineRange = CTLineGetStringRange(line as! CTLine)
           let range: NSRange = NSRange(location: lineRange.location, length: lineRange.length)
           res.append((self as NSString).substring(with: range) as String)
        }

        return res
    }
}
