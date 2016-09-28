//
//  NSRange+Reddity.swift
//  Reddity
//  
// Copyright (c) 2016 Qiang Guo. All rights reserved.
// 

import Foundation

extension NSRange {
    enum NSRangeShrinkage {
        case Both
        case Left
        case Right
    }

    func shrinkBy(amount: Int, option: NSRangeShrinkage = .Both) -> NSRange {
        guard amount > 0 else {
            return self
        }
        
        var l, r, location: Int?
        var length = self.length
        if option == .Both || option == .Left {
            l = amount
        }
        if option == .Both || option == .Right {
            r = amount
        }
        if (l ?? 0) + (r ?? 0) >= length {
            return NSMakeRange(NSNotFound, 0)
        }
        
        if let l = l {
            location = self.location + l
            length   = length - l
        }
        if let r = r {
            length = length - r
        }
        
        return NSMakeRange(location ?? self.location, length)
    }
}
