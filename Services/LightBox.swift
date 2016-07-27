//
//  LightBox.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-13.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation
import Kanna

struct LightBox {
    let url: NSURL
    
    init(withUrl url: String) {
        self.url = NSURL(string: url) ?? NSURL()
    }
    
    typealias HandlerType = (title: String?, description: String?, titleImage: String?) -> Void
    
    func load(completion: HandlerType) -> Void {
        guard !self.url.absoluteString.isEmpty else {
            completion(title: nil, description: nil, titleImage: nil)
            return
        }
        
        NSURLSession.sharedSession().dataTaskWithURL(self.url) { (data, response, error) in
            if let response = response  where 200..<300 ~= (response as! NSHTTPURLResponse).statusCode {
                if let html = String(data: data!, encoding: NSUTF8StringEncoding), let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
                    let imageUrl = doc.at_xpath("//meta[@property='og:image']/@content")?.text ?? doc.at_xpath("//meta[@name=\"thumbnail\"]/@content")?.text
                    completion(title: doc.title,
                               description: doc.at_xpath("//meta[@name=\"description\"]/@content")?.text,
                               titleImage: imageUrl)
                    return
                }
            }
            
            completion(title: nil, description: nil, titleImage: nil)
            }.resume()
    }
}
