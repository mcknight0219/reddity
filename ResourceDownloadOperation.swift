//
//  ResourceDownloadOperation.swift
//  Reddity
//
//  Created by Qiang Guo on 16/10/4.
//  Copyright © 2016年 Qiang Guo. All rights reserved.
//

import Foundation

class ResourceDownloadOperation: NSOperation {
    let URL: NSURL
    
    init(URL: NSURL) {
        self.URL = URL
    }
    
    override func main() {
        guard !self.cancelled else { return }
        
        NSURLSession.sharedSession().downloadTaskWithURL(self.URL) { url, _, _ in
            
        }
    }
}
