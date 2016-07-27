//
//  NSURLSession+Reddity.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-02.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation

extension NSURLSession {
    func synchronousDataTaskWithURL(request: NSURLRequest) -> (NSData?, NSURLResponse?, NSError?) {
        var data: NSData?, response: NSURLResponse?, error: NSError?
        let semaphore = dispatch_semaphore_create(0)
        
        dataTaskWithRequest(request) {
            data = $0; response = $1; error = $2
            dispatch_semaphore_signal(semaphore)
        }.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return (data, response, error)
    }
}