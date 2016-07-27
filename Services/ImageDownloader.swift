//
//  ImageDownloader.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-14.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

enum ResizeMode {
    case AspectFill
    case AspectFit
}

class ImageDownloader: NSObject {
    
    static let sharedInstance = ImageDownloader()
    
    var session: NSURLSession?
    let cache = NSCache()
    var imageProcessQueue = {
        return dispatch_queue_create("reddity.image.process.queue", DISPATCH_QUEUE_SERIAL)
    }()
    
    override init() {
        super.init()
        
        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        config.HTTPMaximumConnectionsPerHost = 3
        self.session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        self.cache.countLimit = 100
    }
    
    typealias SessionHandler = (UIImage?) -> Void
    
    func downloadImageAt(url: NSURL, completion: SessionHandler) {
        self.downloadImageAt(url, resizeMode: nil, size: nil, completion: completion)
    }
    
    func downloadImageAt(url: NSURL, resizeMode: ResizeMode?, size: CGSize?, completion: SessionHandler) {
        
        if let image = self.cache.objectForKey(url) as? UIImage {
            completion(image)
            return
        }
        
        self.session?.dataTaskWithURL(url) { (data, response, error) in
            if let data = data {
                dispatch_async(self.imageProcessQueue) {
                    if let image = UIImage(data: data) {
                        // We only cache the original size of the image
                        self.cache.setObject(image, forKey: url)
                        completion(image)
                        return
                    }

                    completion(nil)
                }
            }
        }.resume()
    }
}

// Just to make compiler happy
extension ImageDownloader: NSURLSessionDelegate {
    
}