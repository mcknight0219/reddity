//
//  Comment.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-12.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation

struct Comment: ResourceType {
    enum ParentType {
        case Comment
        case Link
    }
    
    let listType: ListType = .Comment
    let id: String
    let name: String
    let parentType: ParentType
    let parent: String
    let text: String
    let createdAt: NSDate
    let score: Int
    
    let replies = [Comment]()
    
    init(id: String, parent: String, text: String, timestampString: String, score: Int) {
        self.id = id
        self.name = "\(self.listType.description)\(self.id)"
        self.parentType = parent.startsWith(ListType.Link.description) ? .Link : .Comment
        self.parent = parent
        self.text = text
        self.createdAt = NSDate(timeIntervalSince1970: Double(timestampString)!)
        self.score = score
    }
    
    func hasReplies() -> Bool {
        return !self.replies.isEmpty
    }
    
    func isTopLevel() -> Bool {
        return self.parentType == .Link
    }
    
    // Get number of replies recursively
    func totalReplies() -> Int {
        return replies.reduce(0) { (sum, comment) -> Int in
            return sum + comment.totalReplies()
        }
    }
}