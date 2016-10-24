//
//  Listing.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-12.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation

enum ListType: String, CustomStringConvertible {
    case Comment = "t1_"
    case Account = "t2_"
    case Link    = "t3_"
    case Message = "t4_"
    case Subreddit = "t5_"
    
    var description: String {
        return self.rawValue
    }
}

protocol Listing {
    var listType: ListType { get }
}
