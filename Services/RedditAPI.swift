//
//  RedditAPI.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-06.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation
import RxSwift
import Moya

enum RedditAPI {
    case XApp
    
    case Me
    case FrontPage(after: String)
    case Subreddit(name: String, after: String)
    case SearchTitle(query: String, limit: Int?, after: String?)
    case SearchSubreddit(query: String, limit: Int?, after: String?)
}

extension RedditAPI: TargetType {
    var path: String {
        switch self {
        case .XAPP:
            return ""

        case .Me:
            return "/api/v1/me"

        case .FrontPage:
            return "/"

        case .Subreddit(let name, let _):
            return "/r/\(name)"

        case .SearchTitle:
            return "/search"

        case .SearchSubreddit:
            return "/subreddits/search"
        }
    }

    var base: String {
        switch self {
        case .XApp:
            return "https://www.reddit.com"
        default:
            return "https://oauth.reddit.com"
        }
    }

    var baseURL: NSURL { return NSURL(string: base)! }

    var parameters: [String: AnyObject]? {
        switch self {
        case .FrontPage(let after):
            return ["raw_json": "1", "after": after]

        case .Subreddit(let _, let after):
            return ["raw_json": "1", "after": after]
            
        case .SearchTitle(let q, let limit, let after):
            return ["q": q, "limit": limit ?? 45, "after": after ?? ""]

        case .SearchSubreddit(let q, let limit, let after):
            return ["q": q, "limit": limit ?? 45, "after": after?? ""]
        } 
    }

    var method: Moya.Method {
        switch self {
        case .XApp:
            return .POST
        default:
            return .GET
        }
    }
}

