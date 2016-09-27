//
//  NSMutableAttributedString+Reddity.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-25.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    typealias MatchedAction = (Range, NSMutableAttributedString) -> NSAttributedString

    let NotFoundRange = NSRangeMake(NSNotFound, 0)

    /**
     This function finds all matched parts and applies the callbacks on each. The returned
     value from callback is then used to substitute the matched part. 
     
     @discussion this function returns `self` to allow chainning actions. 
     @param ofPattern String
     @param action    MatchedAction use this returned value to substitute into self
     */
    func replaceOccurrence(ofPattern pattern: String, action: MatchedAction?) -> NSMutableAttributedString {
        guard action != nil else {
            return self
        }

        guard !pattern.isEmpty && self.length > 0 else {
            return self
        }

        var limit = NSRangeMake(0, self.length)
        while true {
            let r = self.string.rangeOfString(pattern, .RegularExpressionSearch, limit)
            if r == NotFoundRange { break }
            let mod = action?(r, self)
            self.replaceCharactersInRange(r, withAttributedString: mod)
            
            limit = NSRangeMake(r.location + mod.length, self.length - r.location - mod.length)
        }
        
        return self
    }

}
