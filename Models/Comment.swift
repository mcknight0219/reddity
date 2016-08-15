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
    
    var replies = [Comment]()
    
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

    mutating func addReply(aComment: Comment) {
        if self.replies.filter { $0.id == aComment.id }.count > 0 { return }
        self.replies.append(aComment)
    }

    /**
     * The sorting occurs on flat level under the parent. The 
     * popularity
     */
    mutating func sortByPopularity() {
        if self.replies.count < 2 { return }
        self.replies.sort { $0.score < $1.score }
    }

    mutating func sortByDate() {
        if self.replies.count < 2 { return }
        self.replies.sort { $0.createdAt < $1.createdAt }
    }
}

func commentsParser(json: JSON) -> [Comment] {
    let treeJson = json[1]["data"]["children"]

    // The replies that direct to post
    var tops = [Comment]()
    for (_, commentJson):(String, JSON) in treeJson {
        if let comment = commentParser(commentJson) {
            top.append(comment)
        }
    }

    return tops
}

internal func commentParser(json: JSON) -> Comment? {
    var comment = Comment(json["id"].stringValue, parent: json["parent_id"].stringValue, text: json["body"], timestamp: json["created"].stringBalue, score: json["ups"].intValue)
    for (_, replyJson): (String, JSON) in json["replies"] {
        var reply = commentParser(replyJson)
        if let reply = reply {
            comment.addReply(reply)
        }
    }

    return comment
}
