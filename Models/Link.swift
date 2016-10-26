//
//  Link.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-07.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation
import SwiftyJSON

enum SelfType {
    case NotSelf
    case SelfText(text: String)
}

struct Link: Listing {
    let title: String
    let id: String
    let url: String
    let numberOfComments: Int
    let ups: Int
    let downs: Int
    let selfType: SelfType
    let subreddit: String
    let createdAt: NSDate
    var thumbnail: String?
    
    var name: String {
        get {
            return "\(self.listType.description)\(self.id)"
        }
    }
    
    lazy var viewModel: LinkViewModel = {
        return LinkViewModel(link: self)
    }()

    let listType: ListType = .Link

    var rawJsonString: String?
    
    init(id: String, title: String, url: String, subreddit: String, ups: Int, downs: Int, numberOfComments: Int, timestamp: Double, selfType: SelfType = .NotSelf, thumbnail: String?) {
        self.title = title
        self.id = id
        self.url = url
        self.subreddit = subreddit
        self.numberOfComments = numberOfComments
        self.ups = ups
        self.downs = downs
        self.createdAt = NSDate(timeIntervalSince1970: timestamp)
        self.selfType = selfType
        self.thumbnail = thumbnail
    }
}

func linkParser(json: JSON) -> [Link] {
    var result = [Link]()
    
    let linksJSON = json["data"]["children"]
    for (_, linkJSON):(String, JSON) in linksJSON {
        let content = linkJSON["data"]
        
        var link = Link(id: content["id"].stringValue,
                        title: content["title"].stringValue,
                        url: content["url"].stringValue,
                        subreddit: content["subreddit"].stringValue,
                        ups: content["ups"].intValue,
                        downs: content["downs"].intValue,
                        numberOfComments: content["num_comments"].intValue,
                        timestamp: content["created"].doubleValue,
                        selfType: content["is_self"].boolValue ? .SelfText(text: content["selftext"].stringValue) : .NotSelf,
                        thumbnail: content["thumbnail"].string)
        link.rawJsonString = content.rawString()
        result.append(link)
    }
    
    return result
}
