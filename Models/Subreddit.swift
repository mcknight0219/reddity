//
//  Subreddit.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-07.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation
import SwiftyJSON


struct Subreddit: ResourceType {
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

func subredditParser(json: JSON) -> Subreddit? {
    return Subreddit(id: json["id"].stringValue,
                              displayName: json["display_name"].stringValue,
                              description: json["public_description"].stringValue,
                              title: json["title"].stringValue,
                              subscribers: json["subscribers"].intValue,
                              headerImageUrl: json["header_img"].stringValue)
}

func subredditsParser(json: JSON) -> [Subreddit] {
    let subsJson = json["data"]["children"]
    
    var subreddits = [Subreddit]()
    for (_, subJson):(String, JSON) in subsJson {
        let content = subJson["data"]
        
        if let subreddit = subredditParser(content) {
            subreddits.append(subreddit)
        }
    }
    
    return subreddits
}