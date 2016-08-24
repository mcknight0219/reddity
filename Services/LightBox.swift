//
//  LightBox.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-13.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation
import Kanna


class LightBox {
    static let sharedInstance = LightBox()
    
    let cache = NSCache()
   
    typealias HandlerType = (title: String?, description: String?, imageURL: NSURL?) -> Void
    
    func load(URL: NSURL, completion: HandlerType) -> Void {
        guard !URL.absoluteString.isEmpty else {
            completion(title: nil, description: nil, imageURL: nil)
            return
        }

        // Callback immediately if the previous result is cached
        if let url = cache.objectForKey(URL) as? NSURL {
            completion(title: "", description: "", imageURL: url)
            return
        }
        
        NSURLSession.sharedSession().dataTaskWithURL(URL) { (data, response, error) in
            if let response = response  where 200..<300 ~= (response as! NSHTTPURLResponse).statusCode {
                if let html = String(data: data!, encoding: NSUTF8StringEncoding), let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
                    let url = doc.at_xpath("//meta[@property='og:image']/@content")?.text ?? doc.at_xpath("//meta[@name=\"thumbnail\"]/@content")?.text
                    let title = doc.title ?? ""
                    let description = doc.at_xpath("//meta[@name=\"description\"]/@content")?.text ?? ""
                    completion(title: title, description: description, imageURL: NSURL(string: url!))
                    
                    self.cache.setObject(NSURL(string: url!)!, forKey: URL, cost: 1)
                    return
                }
            } else {  
                completion(title: nil, description: nil, imageURL: nil)

            }
        }.resume()
    }
}
