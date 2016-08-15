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
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true) {
        
        params.forEach { components.appendQueryItem(name: $0.0, value: $0.1) }
        if let result = components.URL {
            url = result
        } else {
            print("Failure adding query components to URL")
        }
    }
    
    let request = NSMutableURLRequest(URL: url)
    request.addValue("bearer \(TokenService.sharedInstance.token)", forHTTPHeaderField: "Authorization")
    request.addValue(UIApplication.userAgent(), forHTTPHeaderField: "User-Agent")
    
    NetworkActivityIndicator.incrementActivityCount()
    session.dataTaskWithRequest(request) { (data, response, error) in
        NetworkActivityIndicator.decreaseActivityCount()
        if let response = response as? NSHTTPURLResponse {
            if 200..<300 ~= response.statusCode {
                let json = JSON(data: data!)
                
                var parsedResource: A?
                switch json.type {
                    // The comments api will return an array: 1st element is the post itself; 2nd is the comments tree itself
                    case .Array:
                    parsedResource = resource.parser(json)
                    default:
                    parsedResource = resource.parser(json["data"])
                }
                completion(parsedResource)
            }
            else {
                print("API request failure: \(response.statusCode)")
                completion(nil)
            }
        }
    }.resume()
}
