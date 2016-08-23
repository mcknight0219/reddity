//
//  Link.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-07.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation
import SwiftyJSON

enum LinkType {
    case News
    case Image
    case Text
    case Video
    case Unknown
}

enum SelfType {
    case NotSelf
    case SelfText(text: String)
}

var afterName: String?


struct Link: ResourceType {
    let title: String
    let id: String
    let url: NSURL
    let listType: ListType = .Link
    let numberOfComments: Int
    let name: String
    let ups: Int
    let downs: Int
    let selfType: SelfType
    let subreddit: String
    let createdAt: NSDate
    let ratio: Float
    
    typealias Width = String
    typealias ThumbnailUrl = String
    var thumbnails: [Width:ThumbnailUrl]
    
    init(id: String, title: String, url: String, subreddit: String, ups: Int, downs: Int, numberOfComments: Int, timestamp: Double, selfType: SelfType = .NotSelf, previews: [Width:ThumbnailUrl], ratio: Float) {
        self.title = title
        self.id = id
        self.subreddit = subreddit
        self.numberOfComments = numberOfComments
        self.ups = ups
        self.downs = downs
        self.createdAt = NSDate(timeIntervalSince1970: timestamp)
        self.selfType = selfType
        self.thumbnails = previews
        self.ratio = ratio
        self.name = "\(self.listType.description)\(self.id)"

        var URL = url
        if URL.isShortcutImgurURL() { URL = URL + ".png" }
        if URL.isGifvURL() { URL.substringToIndex(URL.characters.count - 5) + ".mp4" }
        
        self.url = NSURL(string: URL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
    }

    func isURLGif() -> Bool {
        if let components = NSURLComponents(URL: self.url, resolvingAgainstBaseURL: false), 
            let path = components.path {
                return NSString(string: path).pathExtension == "gif"
            }

        return false
    }
    
    func type() -> LinkType {
        switch self.selfType {
        case .SelfText(_):
            return .Text
        default: break
        }
        
        switch self.url.absoluteString.mediaType() {
        case .Unknown:
            return .News
        case .Image:
            return .Image
        case .Video:
            return .Video
        }
    }
    
    func mostSuitableThumbnailUrl(width: Int) -> NSURL? {
        switch self.selfType {
        case .SelfText(_):
            return nil
        default: break
        }
        
        guard self.thumbnails.count > 0 else {
            return nil
        }
        
        let candidates = self.thumbnails.keys.filter { Int($0) > width }
        if candidates.count > 0 {
            return NSURL(string: self.thumbnails[candidates.minElement()!] ?? "")
        } else {
            return nil
        }
    }
}

func linkParser(json: JSON) -> [Link] {
    var result = [Link]()
    let linksJSON = json["children"]
    
    if let after = json["after"].string {
        afterName = after
    }
    
    for (_, linkJSON):(String, JSON) in linksJSON {
        let content = linkJSON["data"]
        
        var previews: [String: String] = [:]
        var ratio: Float?
        if let dict = content["preview"]["images"][0].dictionary {
            if let source = dict["source"] {
                let k = source["width"].stringValue
                let v = source["url"].stringValue
                ratio = source["width"].floatValue / source["height"].floatValue
                previews[k] = v
            }
            
            if let resolutions = dict["resolutions"] {
                for (_, json): (String, JSON) in resolutions {
                    previews[json["width"].stringValue] = json["url"].stringValue
                    if ratio == nil {
                        ratio = json["width"].floatValue / json["height"].floatValue
                    }
                }
            }
        }
        
        let link = Link(id: content["id"].stringValue,
                        title: content["title"].stringValue,
                        url: content["url"].stringValue,
                        subreddit: content["subreddit"].stringValue,
                        ups: content["ups"].intValue,
                        downs: content["downs"].intValue,
                        numberOfComments: content["num_comments"].intValue,
                        timestamp: content["created"].doubleValue,
                        selfType: content["is_self"].boolValue ? .SelfText(text: content["selftext"].stringValue) : .NotSelf,
                        previews: previews, ratio: ratio ?? 0.0)
        result.append(link)
    }
    
    return result
}
