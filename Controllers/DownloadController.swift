//
//  DownloadController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-25.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import SwiftyJSON

@objc protocol DowloadControllerDelegate {

}

class DownloadController {

  // MARK: Properties

  var delegate: DownloadControllerDelegate?

  var subreddits = [Subreddit]()

  var tasks = [NSURLSessionDataTask]()

  var finished: [Bool]

  var busy = false

  init(subreddits: [Subreddit]) {
    self.subreddits = subreddits
    self.finished = (0..<self.subreddits.count).map { _ in return false }
  }

  /**
   * Start downloading all resources to offline storage. This is the publicly     
   * exposed API of `DownloadController` 
   */
  public func start() {
    guard self.subreddits.count > 0 && !busy else {
      return
    }

    self.subreddits.forEach { 
      self.startArchiving(forSubreddit: $0)
    }    
  }

    /**
     * Stop all currently downloading task
     */
     public func stop() {
      for (i, e) in self.finished.enumerate() {
        if !e { self.tasks[i].stop() }
      }
    }

    private func startArchiving(forSubreddit aSub: Subreddit) {

    } 
  }
