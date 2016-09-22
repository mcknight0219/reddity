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
       
    let listType: ListType = .Comment
    let id: String
    let name: String
    
    /**
     A hack to work around `stored property that references itself` for struct value type

     @see https://gist.github.com/zats/c39dbd9b0017fb3b77dd37be744cf474
     */
    private var _parent: [Comment]?

    var parent: Comment? {
        set {
            _parent = newValue.map {[$0]}
        }

        get {
            return _parent?.first
        }
    }

    // Level of comments in comments tree
    lazy var level: Int = {
        var ret = 0
        
        while var p = self.parent {
            p = p.parent
            ret = ret + 1
        }

        return ret
    }() 

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

    init(id: String, parent: Comment?, text: String, timestampString: String, ups: Int, downs: Int, user: String) {
        self.id = id
        self.name = "\(self.listType.description)\(self.id)"
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
            reply.setStatusAll(false)
        }
    }

    /**
     Return the median score of replies to this comment.
     */
    func getMedianScore() -> Float {
        let n = self.replies.count
        guard n > 0 { return 0 }

        if n % 2 == 0 {
            return Float(self.replies[n/2-1].score + self.replies[n/2].score) / 2.0
        } else {
            return Float(self.replies[n/2])
        }
    }

    /**
     This function creates an array of all children comments. It follows a DFS fashion so
     it suits displaying them on screen.

     @note the flattened list includes the comment itself as first 
     */
    func flatten() -> [Comment] {
        var ret = [self]
        guard replies.count > 0 { return ret }

        replies.map { ret.appendContentsOf($0.flatten) }

        return ret
    }
}


public func makePlaceholder() {
    var ret = Comment(id: "", parent: nil, text: "", timestampString: "", ups: 0, downs: 0, user: "")
    ret.isPlaceholder = true

    return ret
}

private var _commentsParsedDict = [String:Comment]()

func commentsParser(json: JSON) -> [Comment] {
    let treeJson = json[1]["data"]["children"]

    _commentsParsedDict.removeAll(false)

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
    
    // Figure out parent, it's always available because we walk comments tree in top-down fashion
    let parentId = json["parent_id"].stringValue
    
    var parent: Comment?
    if parentId.startsWith("t3_") {
        // The root comments have link itself as parent
        parent = nil
    
    } else {
    
        parent = _commentsParsedDict[parent.substringFromIndex(parentId.startIndex.advancedBy(3))]
    
    }

    var comment = Comment(id: json["id"].stringValue, parent: parent, text: json["body"].stringValue, timestampString: json["created"].stringValue, ups: json["ups"].intValue, downs: json["downs"].intValue, user: json["author"].stringValue)
    for (_, replyJson): (String, JSON) in json["replies"]["data"]["children"] {
        let reply = commentParser(replyJson["data"])
        if let reply = reply {
            comment.addReply(reply)
        }
    }

    _commentsParsedDict[comment.id] = comment

    return comment
}

