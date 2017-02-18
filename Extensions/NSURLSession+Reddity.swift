//
//  NSURLSession+Reddity.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-02.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation

extension URLSession {
    func synchronousDataTaskWithURL(request: NSURLRequest) -> (NSData?, URLResponse?, NSError?) {
        var data: NSData?, response: URLResponse?, error: NSError?
        let semaphore = DispatchSemaphore(value: 0)

        dataTask(with: request as URLRequest) {
            data = $0 as NSData?; response = $1; error = $2 as NSError?
            semaphore.signal()
        }.resume()
        
        switch semaphore.wait(timeout: DispatchTime.distantFuture) {
        case .success:
            return (data, response, error)
        default:
            return (nil, nil, error)
        }
    }
}
