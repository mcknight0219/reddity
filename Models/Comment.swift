//
//  Comment.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-12.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation
import SwiftyJSON


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
    let ups: Int
    let downs: Int
    var score: Int {
        get {
            return ups - downs
        }
    }
    let user: String
    
    var replies = [Comment]()
    // UI related property: whether to show the comment
    var isShow: Bool {
        didSet {
            if !isShow {
                for var child in replies {
                    child.isShow = isShow
                }
            } 
        }
    } 
    
    var isPlaceholder: Bool = false

    lazy var level: Int = {
        let l = 1
        var p = self.parent
        while !p.isEmpty {
            p = p.parent
            l++
        }

        return l
    }()

    init(id: String, parent: String, text: String, timestampString: String, ups: Int, downs: Int, user: String) {
        self.id = id
        self.name = "\(self.listType.description)\(self.id)"
        self.parentType = parent.startsWith(ListType.Link.description) ? .Link : .Comment
        self.parent = parent
        self.text = text
        self.createdAt = NSDate(timeIntervalSince1970: Double(timestampString)!)
        self.ups = ups
        self.downs = downs
        self.user = user
        
        self.isShow = false
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

    mutating func removeReplies() {

        self.replies.removeAll()
    
    }

    mutating func addReply(aComment: Comment) {
        if (self.replies.filter { $0.id == aComment.id }).count > 0 { return }
        self.replies.append(aComment)
    }

    /**
     * The sorting occurs on flat level under the parent. The 
     * popularity
     */
    mutating func sortByPopularity() {
        if self.replies.count < 2 { return }
        self.replies.sortInPlace { $0.score < $1.score }
    }

    mutating func sortByDate() {
        if self.replies.count < 2 { return }
        self.replies.sortInPlace { $0.createdAt.compare($1.createdAt) == .OrderedAscending }
    }

    mutating func setStatusAll(isHidden: Bool) {
        if isHidden {
            self.isShow = false // this will handle all children nodes
            return
        }

        self.isShow = true
        for reply in replies {
            reply.setAllStatus(false)
        }
    }

    /**
     Return the median score of replies to this comment.
     */
    func getMedianScore() -> Float {
        let n = self.replies.count
        guard n > 0 { return 0 }

        if n % 2 == 0 {
            return Float(self.replies[n / 2 -1].score + self.replies[n / 2].score) / 2.0
        } else {
            return self.replies[n / 2]
        }
    }
}


public func makePlaceholder() {
    var ret = Comment(id: "", parent: "", text: "", timestampString: "", ups: 0, downs: 0, user: "")
    ret.isPlaceholder = true

    return ret
}

func commentsParser(json: JSON) -> [Comment] {
    let treeJson = json[1]["data"]["children"]

    // The replies that direct to post
    var tops = [Comment]()
    for (_, commentJson):(String, JSON) in treeJson {
        if let comment = commentParser(commentJson["data"]) {
            tops.append(comment)
        }
    }

    return tops
}

internal func commentParser(json: JSON) -> Comment? {
    guard !json["body"].stringValue.isEmpty else{
        return nil
    }
    
    var comment = Comment(id: json["id"].stringValue, parent: json["parent_id"].stringValue, text: json["body"].stringValue, timestampString: json["created"].stringValue, ups: json["ups"].intValue, downs: json["downs"].intValue, user: json["author"].stringValue)
    for (_, replyJson): (String, JSON) in json["replies"]["data"]["children"] {
        let reply = commentParser(replyJson["data"])
        if let reply = reply {
            comment.addReply(reply)
        }
    }

    return comment
}

