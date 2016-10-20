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

enum GrantType: String {
    /// User auth
    case Code = "authorization_code"
    /// No user, only supports browsing
    case Installed = "https://oauth.reddit.com/grants/installed_client"
    case Refresh = "refresh_token"
}

enum RedditAPI {
    case XApp(grantType: GrantType, code: String?)
    
    case Me
    case FrontPage(after: String)
    case Subreddit(name: String, after: String)
    case SearchTitle(query: String, limit: Int?, after: String?)
    case SearchSubreddit(query: String, limit: Int?, after: String?)
}

extension RedditAPI: TargetType {
    var path: String {
        switch self {
        case .XApp:
            return "/api/v1/access_token"

        case .Me:
            return "/api/v1/me"

        case .FrontPage:
            return "/"

        case .Subreddit(let name, _):
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
        case .XApp(let grant, let code):
            switch grant {
            case .Code:
                return ["grant_type": grant.rawValue, "code": code!, "redirect_uri": "reddity://response"]
            case .Installed:
                return ["grant_type": grant.rawValue, "device_id": NSUUID().UUIDString]
            default:
                return ["grant_type": grant.rawValue, "refresh_token": XAppToken().refreshToken!]
            }

        case .FrontPage(let after):
            return ["raw_json": "1", "after": after]

        case .Subreddit( _, let after):
            return ["raw_json": "1", "after": after]
            
        case .SearchTitle(let q, let limit, let after):
            return ["q": q, "limit": limit ?? 45, "after": after ?? ""]

        case .SearchSubreddit(let q, let limit, let after):
            return ["q": q, "limit": limit ?? 45, "after": after ?? ""]
        default:
            return nil
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
    
    var multipartBody: [MultipartFormData]? {
        return nil
    }
    
    var sampleData: NSData {
        return NSData()
    }
}

func url(route: TargetType) -> String {
    return (route.baseURL.URLByAppendingPathComponent(route.path)?.absoluteString)!
}

