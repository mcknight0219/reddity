//
//  RTWebImageManager.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-02.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

extension NSProgress {
    func finished() -> Bool {
        return self.completedUnitCount == self.totalUnitCount
    }
}

typealias ProgressHandler = (recevied: Int64, expected: Int64) -> Void
typealias CompletionHandler = (image: UIImage?, result: Result) -> Void

enum RTWebImageError: ErrorType {
    case NoNetworkConnection
    case Timeout
    case InvalidResponse
}

enum Result {
    case Success
    case Failure(RTWebImageError)
}

class RTWebImageManager: NSObject {
    
    struct Reporter {
        let url: NSURL
        weak var task: NSURLSessionDataTask?
        var progress: ProgressHandler?
        var completion: CompletionHandler?
        
        let _progress = NSProgress()
        let _tempData = NSMutableData()
    }
    
    static let sharedManager = RTWebImageManager()
    
    var session: NSURLSession?
    let cache = RTCache(name: "webimage.downloader", maxSizeInMb: 25)
    var tasks = [NSURLSessionDataTask: Reporter]()
    
    override init() {
        super.init()
        
        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        config.HTTPMaximumConnectionsPerHost = NSProcessInfo.processInfo().activeProcessorCount
        session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    func createImageDownloadTask(url: NSURL, progress: ProgressHandler?, completion: CompletionHandler?) -> NSURLSessionDataTask {
        let task = self.session!.dataTaskWithURL(url)
        let reporter = Reporter(url: url, task: task, progress: progress, completion: completion)
        tasks[task] = reporter
        
        return task
    }
}

extension RTWebImageManager: NSURLSessionDelegate {}

extension RTWebImageManager: NSURLSessionDataDelegate {
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        if let reporter = self.tasks[dataTask] {
            reporter._progress.totalUnitCount = response.expectedContentLength
            reporter.progress?(recevied: 0, expected: reporter._progress.totalUnitCount)
            
            completionHandler(.Allow)
        } else {
            dataTask.cancel()
            completionHandler(.Cancel)
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if let reporter = self.tasks[dataTask] {
            reporter._progress.completedUnitCount += data.length
            reporter._tempData.appendData(data)
            
            if reporter._progress.finished() {
                let img = UIImage(data: reporter._tempData)
                reporter.completion?(image: img, result: .Success)
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) { [weak self] in
                    self?.cache.setObject(img!, forKey:reporter.url, cost: reporter._tempData.length)
                    self?.tasks.removeValueForKey(reporter.task!)
                }
            } else {
                reporter.progress?(recevied: reporter._progress.completedUnitCount, expected: reporter._progress.totalUnitCount)
            }
        }
    }
}