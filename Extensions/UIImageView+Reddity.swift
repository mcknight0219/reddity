//
//  UIImageView+Reddity.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-12.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit

extension UIImageView {
    private struct AssoicatedKeys {
        static var imageSetterKey = "webimage.download.task"
    }
    
    var setter: NSURLSessionDataTask? {
        get {
            return objc_getAssociatedObject(self, &AssoicatedKeys.imageSetterKey) as? NSURLSessionDataTask
        }
        
        set {
            if let task = newValue {
                objc_setAssociatedObject(self, &AssoicatedKeys.imageSetterKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    func setImageWithURL(url: NSURL, placeholder: UIImage?, manager: RTWebImageManager, progress: ProgressHandler?, completion: CompletionHandler?) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            self.cancelCurrentTask()
            
            if let cachedImage = manager.cache.object(forKey: url) as? UIImage {
                if let completion = completion {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(image: cachedImage, result: .Success)
                    }
                }
                return
            }

            if let placeholder = placeholder {
                dispatch_async(dispatch_get_main_queue()) {
                    self.image = placeholder
                }
            }
            
            weak var task = manager.createImageDownloadTask(url, progress: progress, completion: completion)
            self.setter = task
            task?.resume()
        }
    }
    
    private func cancelCurrentTask() {
        if let task = self.setter {
            if task.state == .Running || task.state == .Suspended {
                NetworkActivityIndicator.decreaseActivityCount()
                print("A task is cancelled: \(task.taskDescription)")
                task.cancel()
            }
            // clear the setter
            setter = nil
        }
    }
}

