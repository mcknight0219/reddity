//
//  String+Reddity.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-25.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

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
}

extension String {

    func test(pattern: String) -> Bool {
        guard !isEmpty && !pattern.isEmpty else {
            return false
        }

        return rangeOfString(pattern, options: .RegularExpressionSearch) != nil
    }
}
