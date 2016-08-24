//
//  LightBox.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-13.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation
import Kanna

struct LightBoxMeta {
    let title: String
    let description: String
    let URL: NSURL
}

class LightBox {
    static let sharedInstance = LightBox()
    
    let cache = NSCache()
   
    typealias HandlerType = (title: String?, description: String?, imageURL: NSURL?) -> Void
    
    func load(URL: NSURL, completion: HandlerType) -> Void {
        guard !URL.absoluteString.isEmpty else {
            completion(title: nil, description: nil, titleImage: nil)
            return
        }

        // Callback immediately if the previous result is cached
        if let meta = cache.object(forKey: URL) as? LightBoxMeta {
            completion(meta.title, meta.description, meta.URL)
            return
        }
        
        NSURLSession.sharedSession().dataTaskWithURL(URL) { (data, response, error) in
            if let response = response  where 200..<300 ~= (response as! NSHTTPURLResponse).statusCode {
                if let html = String(data: data!, encoding: NSUTF8StringEncoding), let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
                    let urlStr = doc.at_xpath("//meta[@property='og:image']/@content")?.text ?? doc.at_xpath("//meta[@name=\"thumbnail\"]/@content")?.text
                    let url = NSURL(string: urlStr)
                    let title = doc.title
                    let description = doc.at_xpath("//meta[@name=\"description\"]/@content")?.text ?? ""
                    completion(title: title, description: description, imageURL: url)
                    
                    cache.setObject(LightBoxMeta(title: title, description: description, URL: url), forKey: URL, cost: 1)
                    return
                }
            } else {  
                completion(title: nil, description: nil, titleImage: nil)

            }
        }.resume()
    }
}
