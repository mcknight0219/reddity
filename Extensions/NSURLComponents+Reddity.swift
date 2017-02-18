//
//  NSURLComponents+Reddity.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-12.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation

extension URLComponents {
    mutating func appendQueryItem(name: String, value: String) {
        var queryItems: [URLQueryItem] = self.queryItems ?? [URLQueryItem]()
        queryItems.append(URLQueryItem(name: name, value: value))
        self.queryItems = queryItems
    }
}
