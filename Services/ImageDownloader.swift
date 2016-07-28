//
//  ImageDownloader.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-14.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

enum ResizeMode {
    case AspectFill
    case AspectFit
}

typealias ProgressHandler = (Double) -> Void
typealias FinishHandler = (NSData) -> Void

struct ProgressReporter {
    let task: NSURLSessionDataTask
    let onProgress: ProgressHandler?
    let onFinish: FinishHandler?

    let progress = NSProgress()
    let tempData = NSMutableData()
}

class ImageDownloader: NSObject {
    
    static let sharedInstance = ImageDownloader()
    
    var session: NSURLSession?
    let cache = NSCache()
    var tasks: Dictionary = [NSURLSessionDataTask: ProgressReporter]()

    var imageProcessQueue = {
        return dispatch_queue_create("reddity.image.process.queue", DISPATCH_QUEUE_SERIAL)
    }()
    
    override init() {
        super.init()
        
        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        config.HTTPMaximumConnectionsPerHost = 3
        self.session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
        self.cache.countLimit = 100
    }
    
    typealias SessionHandler = (UIImage?) -> Void
    
    func downloadImageAt(url: NSURL, completion: SessionHandler) {
        self.downloadImageAt(url, resizeMode: nil, size: nil, completion: completion)
    }
    
    func downloadImageAt(url: NSURL, resizeMode: ResizeMode?, size: CGSize?, completion: SessionHandler) {
        
        if let image = self.cache.objectForKey(url) as? UIImage {
            completion(image)
            return
        }
        
        self.session?.dataTaskWithURL(url) { (data, response, error) in
            if let data = data {
                dispatch_async(self.imageProcessQueue) {
                    if let image = UIImage(data: data) {
                        // We only cache the original size of the image
                        self.cache.setObject(image, forKey: url)
                        completion(image)
                        return
                    }

                    completion(nil)
                }
            }
        }.resume()
    }

    // Usefulf to large images such as gif
    func downloadImageWithProgressReport(url: NSURL, onProgress: ProgressHandler?, onFinish: FinishHandler?) {
        if let data = self.cache.objectForKey(url) as? NSData {
            onFinish?(data)
            return
        }

        // Without a completion handler, the delegate method will be used
        let task = self.session!.dataTaskWithURL(url)
        let reporter = ProgressReporter(task: task, onProgress: onProgress, onFinish: onFinish)
        self.tasks[task] = reporter
        task.resume()
    }
}

// Just to make compiler happy
extension ImageDownloader: NSURLSessionDelegate {
}

extension ImageDownloader: NSURLSessionDataDelegate {
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didRecevieResponse response: NSURLResponse) {
        if let reporter = self.tasks[dataTask] {
            reporter.progress.totalUnitCount =  response.expectedContentLength
            reporter.onProgress?(reporter.progress.fractionCompleted)
            
            return
        }
        
        print("Could not find a progress reporter for task: \(dataTask.description)")
    }

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if let reporter = self.tasks[dataTask] {
            reporter.progress.completedUnitCount += data.length
            reporter.tempData.appendData(data)

            if reporter.progress.completedUnitCount == reporter.progress.totalUnitCount {
                reporter.onProgress?(reporter.progress.fractionCompleted)
            } else {
                reporter.onFinish?(reporter.tempData)
            }
            
            return
        }

        print("Could not find a progress reporter for task: \(dataTask.description)")
    }
}