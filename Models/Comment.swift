//
//  Comment.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-12.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation
import SwiftyJSON


struct Comment: Listing, Equatable {
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

    let text: String
    let createdAt: Date
    let ups: Int
    let downs: Int
    var score: Int {
        get {
            return ups - downs
        }
    }
    
    let user: String
    
    var replies = [Comment]()
    var numberOfReplies: Int {
        guard replies.count > 0 else {
            return 0
        }
        return replies.reduce(0) { $0 + $1.numberOfReplies + 1 }
    }

    init(id: String, parent: Comment?, text: String, timestampString: String, ups: Int, downs: Int, user: String) {
        self.id = id
        self.name = "\(self.listType.description)\(self.id)"
        self.text = text
        self.createdAt = Date(timeIntervalSince1970: Double(timestampString)!)
        self.ups = ups
        self.downs = downs
        self.user = user
        self.parent = parent
    }
   
    mutating func addReply(aComment: Comment) {
        if (self.replies.filter { $0.id == aComment.id }).count > 0 { return }
        self.replies.append(aComment)
    }
}

func ==(lhs: Comment, rhs: Comment) -> Bool {
    return lhs.id == rhs.id
}

private var _commentsParsedDict = [String:Comment]()
func commentsParser(json: JSON) -> [Comment] {
    let treeJson = json[1]["data"]["children"]

    _commentsParsedDict.removeAll(keepingCapacity: false)

    // The replies that direct to post
    var tops = [Comment]()
    for (_, commentJson):(String, JSON) in treeJson {
        if let comment = commentParser(json: commentJson["data"]) {
            tops.append(comment)
        }
    }
    
    fixParentRef(seq: &tops)

    return tops
}

internal func fixParentRef(seq: inout [Comment]) {
    for i in 0..<seq.count {
        for j in 0..<seq[i].replies.count {
            seq[i].replies[j].parent = seq[i]
            fixParentRef(seq: &seq[i].replies)
        }
    }
}

internal func commentParser(json: JSON) -> Comment? {
    guard !json["body"].stringValue.isEmpty else{
        return nil
    }
    
    // Figure out parent, it's always available because we walk comments tree in top-down fashion
    let parentId = json["parent_id"].stringValue
    
    var parent: Comment?
    if parentId.startsWith(sub: "t3_") {
        // The root comments have link itself as parent
        parent = nil
    
    } else {
        parent = _commentsParsedDict[parentId.substring(from: parentId.index(parentId.startIndex, offsetBy: 3))]
    }

    var comment = Comment(id: json["id"].stringValue, parent: parent, text: json["body"].stringValue, timestampString: json["created"].stringValue, ups: json["ups"].intValue, downs: json["downs"].intValue, user: json["author"].stringValue)
    _commentsParsedDict[comment.id] = comment
    for (_, replyJson): (String, JSON) in json["replies"]["data"]["children"] {
        let reply = commentParser(json: replyJson["data"])
        if let reply = reply {
            comment.addReply(aComment: reply)
        }
    }

    return comment
}

