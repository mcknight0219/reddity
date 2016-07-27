//
//  NSURLComponents+Reddity.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-12.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation

extension NSURLComponents {
    func appendQueryItem(name name: String, value: String) {
        var queryItems: [NSURLQueryItem] = self.queryItems ?? [NSURLQueryItem]()
        queryItems.append(NSURLQueryItem(name: name, value: value))
        self.queryItems = queryItems
    }
}
