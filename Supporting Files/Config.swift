//
//  Config.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-13.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation

struct Config {
    static let ApiBaseURL = NSURL(string: "https://oauth.reddit.com")!

    static let URLPattern = "(https?|ftp|file)://\\S+"

    static let ImgurResourcePattern = "^.+(imgur.com)/[0-9a-zA-Z]+/?$"
}
