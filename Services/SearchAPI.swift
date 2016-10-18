//
//  SearchAPI.swift
//  Reddity
//
//  Created by Qiang Guo on 2016/10/11.
//  Copyright © 2016年 Qiang Guo. All rights reserved.
//

import Foundation
import SwiftyJSON
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

func apiError(error: String) -> NSError {
    return NSError(domain: "SearchAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: error])
}

class SearchAPI {
    static let sharedAPI = SearchAPI()
    
    private init() {}
    
    private func rx_JSON(URL: NSURL) -> Observable<AnyObject> {
        return NSURLSession.sharedSession()
            .rx_JSON(URL)
    }
    
    func getSearchRestults(query: String) -> Observable<[Subreddit]> {
        let escapedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) ?? ""
        let urlContent = "\(Config.ApiBaseURL)/subreddits/search?q=\(escapedQuery)&limit=50"
        let url = NSURL(string: urlContent)!
        
        let operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        #if !RX_NO_MODULE
        operationQueue.qualityOfService = .UserInitiated
        #endif
        
        return rx_JSON(url)
            .observeOn(OperationQueueScheduler(operationQueue: operationQueue))
            .map { json in
                return subredditsParser(JSON(json))
            }
            .observeOn(MainScheduler.instance)
    }
}

