//
//  RemoteDataService.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-06.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation
import SwiftyJSON

enum Method: String, CustomStringConvertible {
    case POST = "POST"
    case GET = "GET"
    case DELETE = "DELETE"
    case PUT = "PUT"
    
    var description: String {
        return self.rawValue
    }
}

struct Resource<A> {
    let url: String
    let method: Method
    let parser: (JSON) -> A?
}


func apiRequest<A>(base: NSURL, resource: Resource<A>, params: [String:String]?, completion: (A?) -> Void) {
    let session = NSURLSession.sharedSession()
    
    var url = base.URLByAppendingPathComponent(resource.url)
    if let params = params,
        let components = NSURLComponents(URL: url!, resolvingAgainstBaseURL: true) {
        
        params.forEach { components.appendQueryItem(name: $0.0, value: $0.1) }
        if let result = components.URL {
            url = result
        } else {
            print("Failure adding query components to URL")
        }
    }
    
    let request = NSMutableURLRequest(URL: url!)
    request.addValue("bearer \(XAppToken().accessToken!)", forHTTPHeaderField: "Authorization")
    request.addValue(UIApplication.userAgent(), forHTTPHeaderField: "User-Agent")
    
    NetworkActivityIndicator.incrementActivityCount()
    session.dataTaskWithRequest(request) { (data, response, error) in
        NetworkActivityIndicator.decreaseActivityCount()
        if let response = response as? NSHTTPURLResponse {
            if 200..<300 ~= response.statusCode {
                let json = JSON(data: data!)
                completion(resource.parser(json))
            }
            else {
                print("API request failure: \(response.statusCode)")
                completion(nil)
            }
        }
    }.resume()
}
