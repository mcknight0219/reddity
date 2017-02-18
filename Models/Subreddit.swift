//
//  Subreddit.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-07.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation
import SwiftyJSON
import FMDB


struct Subreddit: Listing, Equatable {
    enum SortOrder: String, CustomStringConvertible {
        case Popular = "popular"
        case New = "new"
        case Random = "random"
        
        var description: String {
            return self.rawValue
        }
    }
    
    let listType: ListType = .Subreddit
    let name: String
    let id: String
    let displayName: String
    let description: String

    let title: String
    let subscribers: Int
    
    let headerImage: NSURL?
    var order: SortOrder = .Popular
    // For serialization purpose
    var rawJsonString: String?

    init(id: String, displayName: String, description: String, title: String, subscribers: Int, headerImageUrl: String) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.title = title
        self.subscribers = subscribers
        self.headerImage = NSURL(string: headerImageUrl)
        
        self.name = "\(self.listType.description)\(self.id)"
    }

    
    func listUrl() -> String {
        return "/r/\(self.displayName)/\(self.order.description)"
    }
}

func ==(lhs: Subreddit, rhs: Subreddit) -> Bool {
    return lhs.id == rhs.id
}

func subredditParser(json: JSON) -> Subreddit? {
    var r = Subreddit(id: json["id"].stringValue,
                              displayName: json["display_name"].stringValue,
                              description: json["public_description"].stringValue,
                              title: json["title"].stringValue,
                              subscribers: json["subscribers"].intValue,
                              headerImageUrl: json["header_img"].stringValue)
    r.rawJsonString = json.rawString()
    
    return r
}

func subredditsParser(json: JSON) -> [Subreddit] {
    let subsJson = json["data"]["children"]
    
    var subreddits = [Subreddit]()
    for (_, subJson):(String, JSON) in subsJson {
        let content = subJson["data"]
        
        if let subreddit = subredditParser(json: content) {
            subreddits.append(subreddit)
        }
    }
    
    return subreddits
}

/**
 @parameter rs The current cursor of query results

 @discussion use this function in caution because it doesn't check validity 
 of `rs`
 */
func createSubredditFromQueryResult(rs: FMResultSet) -> Subreddit {
    return Subreddit(id: rs.string(forColumn: "id"), 
                displayName: rs.string(forColumn: "displayName"),
                description: "",
                title: rs.string(forColumn: "title"),
                subscribers: Int(rs.int(forColumn: "subscribers")),
                headerImageUrl: rs.string(forColumn: "imageURL"))
}
