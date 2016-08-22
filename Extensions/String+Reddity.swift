//
//  String+Reddity.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-25.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

enum UrlType {
    case Unknown
    case Image
    case Imgur(String),
    case Video
}

let urlPattern = try! NSRegularExpression(pattern: "^(https?|ftp|file)://.+$", options: .CaseInsensitive)
let imgurPattern = try! NSRegularExpression(pattern: "^.+(imgur.com)/[0-9a-zA-Z]+/?$", options: .CaseInsensitive)

extension String {
    func startsWith(sub: String) -> Bool {
        guard self.characters.count >= sub.characters.count else {
            return false
        }
        
        return self.characters.prefix(sub.characters.count).elementsEqual(sub.characters)
    }
    
    func isImageUrl() -> UrlType {

        guard !isEmpty else { return .Unknown }
        guard urlPattern.matchesInString(self, options: [], range: NSMakeRange(0, self.characters.count)).count > 0 else { return .Unknown }
        
        let ext = NSString(string: self).pathExtension
        if ["bmp", "jpg", "jpeg", "gif", "png"].contains(ext.lowercaseString) {
            return .Image
        } else if imgurPattern.matchesInString(self, options: [], range: NSMakeRange(0, self.characters.count)).count > 0 {
            return .Image
        } else {
            return .Unknown
        }
        
    }

    func heightWithContrained(width: CGFloat, font: UIFont) -> CGFloat {
        let maxRect = CGSize(width: width, height: CGFloat.max)
        let boundingBox = self.boundingRectWithSize(maxRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
    
        return boundingBox.height
    }
}
