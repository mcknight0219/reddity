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

    func shrinkBy(_ amount: Distance, option: NSRangeShrinkage = .Both) -> NSRange? {
        guard amount > 0 else { 
            return self
        }

        var l, r, location, length: Int?
        if option == .Both || options == .Left {
            l = amount
        }
        if option == .Both || options == .Right {
            r = amount
        }
        if l ?? 0 + r ?? 0 >= length {
            return NSRange(NSNotFound, 0)
        }

        if let l = l {
            location = location + amount
            length   = length - amount
        }
        if let r = r {
            length = length - amount
        }

        return NSRange(location, length)
    }
} 