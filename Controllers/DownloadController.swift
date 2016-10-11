//
//  DownloadController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-25.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol DownloadControllerDelegate {
  func downloadControllerDidArchive(subreddit: Subreddit)
  func downloadControllerArchiveCancelled(subreddit: Subreddit)
  func downloadControllerArchiveFailed(subeddit: Subreddit)
  func downloadControllerArhiveProgress(subreddit: Subreddit, expectedNumberOfArticles: Int, finishedNumberOfArticles: Int)
}

class DownloadController {
  // MARK: Properties

  var delegate: DownloadControllerDelegate?

  var subreddits = [Subreddit]()

  var ops = [TimelineDownloadOperation]()

  var finished: [Bool]

  var busy = false

  var queue: NSOperationQueue

  init(subreddits: [Subreddit]) {
    self.subreddits = subreddits
    self.finished = (0..<self.subreddits.count).map { _ in return false }
    self.queue = {
        $0.maxConcurrentOperationCount = 3
        $0.qualityOfService = .Background
        $0.name = "TimelineDownload"
        
        return $0
    }(NSOperationQueue())
  }

  /**
   * Start downloading all resources to offline storage. This is the publicly     
   * exposed API of `DownloadController` 
   */
  func start() {
    guard self.subreddits.count > 0 && !busy else {
      return
    }

    self.subreddits.forEach { self.archive(subreddit: $0)}
  }

    /**
     * Stop all currently downloading task
     */
    func stop() {
      
    }

    private func archive(subreddit aSub: Subreddit) {
      let op = TimelineDownloadOperation(subreddit: aSub, max: 25)
      ops.append(op)
      self.queue.addOperation(op)
    } 
  }
