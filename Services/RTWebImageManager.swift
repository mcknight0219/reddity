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
typealias TransformHandler = (image: UIImage?) -> UIImage?

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
        let progress: ProgressHandler?
        let completion: CompletionHandler?
        let transform: TransformHandler?
        
        let _progress = NSProgress()
        let _tempData = NSMutableData()
    }
    
    static let sharedManager = RTWebImageManager()
    
    var session: NSURLSession?
    //let cache = RTCache(name: "webimage.downloader", maxSizeInMb: 25)
    let cache = NSCache()
    var tasks = NSCache()
    
    override init() {
        super.init()
        
        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        config.HTTPMaximumConnectionsPerHost = NSProcessInfo.processInfo().activeProcessorCount
        session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    func createImageDownloadTask(url: NSURL, progress: ProgressHandler?, transform: TransformHandler?, completion: CompletionHandler?) -> NSURLSessionDataTask {
        let task = self.session!.dataTaskWithURL(url)
        let reporter = Reporter(url: url, task: task, progress: progress, transform: transform, completion: completion)
        tasks.setObject(reporter, forKey: task, cost: 1)
        
        return task
    }

    func cancelTask(aTask: NSURLSessionDataTask?) {
        if let task = aTask {
            self.tasks.removeObjectForKey(task)
            task.cancel()
        }
    }
}

extension RTWebImageManager: NSURLSessionDelegate {}

extension RTWebImageManager: NSURLSessionDataDelegate {
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        if let reporter = self.tasks.objectForKey(key: dataTask) as? Reporter {
            reporter._progress.totalUnitCount = response.expectedContentLength
            reporter.progress?(recevied: 0, expected: reporter._progress.totalUnitCount)
            
            completionHandler(.Allow)
        } else {
            cancelTask(dataTask)
            completionHandler(.Cancel)
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if let reporter = self.tasks[dataTask] {
            reporter._progress.completedUnitCount += data.length
            reporter._tempData.appendData(data)
            
            if reporter._progress.finished() {
                var img = UIImage(data: reporter._tempData)
                if let transform = reporter.transform { img = transform(img) }
                reporter.completion?(image: img, result: .Success)

                dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) { [weak self] in
                    self?.cache.setObject(img!, forKey:reporter.url, cost: reporter._tempData.length)
                    self?.tasks.removeObjectForKey(reporter.task!)
                }
            } else {
                reporter.progress?(recevied: reporter._progress.completedUnitCount, expected: reporter._progress.totalUnitCount)
            }
        }
    }
}
