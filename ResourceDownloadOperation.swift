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
    
    lazy var dest = {
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        return app.storagePath
    }()

    init(URL: NSURL) {
        self.URL = URL
    }
    
    override func main() {
        guard !self.cancelled else { return }
        
        NSURLSession.sharedSession().downloadTaskWithURL(self.URL) { url, _, _ in
            let sys = NSFileManager.defaultManager()
            do {
                try sys.copyItemAtPath(url.path, toPath: dest.stringByAppendingPathComponent(URL.hash))
            } catch let err as NSError {
                print("failed: \(err.localizedDescription)")
            }               
        }
    }
}
