//
//  String+Reddity.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-25.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

enum MediaType {
    case Image
    case Video
    case Unknown
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
    
    func mediaType() -> MediaType  {
        guard !isEmpty else { return .Unknown }
        guard urlPattern.matchesInString(self, options: [], range: NSMakeRange(0, self.characters.count)).count > 0 else { return .Unknown }
        
        let ext = NSString(string: self).pathExtension
        if ["bmp", "jpg", "jpeg", "gif", "png"].contains(ext.lowercaseString) || isShortcutImgurURL() {
            return .Image
        } else if ["mp4", "gifv"].contains(ext.lowercaseString) {
            return .Video  
        } else {
            return .Unknown
        }
    }

    /**
     Check if a url is of format `https://www.imgur.com/aXfgd`
     */
    func isShortcutImgurURL() -> Bool {
        return imgurPattern.matchesInString(self, options: [], range: NSMakeRange(0, self.characters.count)).count > 0     
    }

    func isGifvURL() -> Bool {
        let ext = NSString(string: self).pathExtension
        return ext == "gifv"
    }

    func heightWithContrained(width: CGFloat, font: UIFont) -> CGFloat {
        let maxRect = CGSize(width: width, height: CGFloat.max)
        let boundingBox = self.boundingRectWithSize(maxRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
    
        return boundingBox.height
    }
}
