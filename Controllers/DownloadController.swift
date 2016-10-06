//
//  DownloadController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-25.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import SwiftyJSON

@objc protocol DownloadControllerDelegate {
  optional func downloadControllerDidArchive(subreddit: Subreddit)
  optional func downloadControllerArchiveCancelled(subreddit: Subreddit)
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
      $0.qualityOfService = QOS_BACKGROUND_CLASS
      $0.name = "TimelineDownload"
      $0.isSuspended = true
      $0.addObserver(self, forKeyPath: "operations", options: [], context: nil)
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
    this.queue.isSuspended = false    
  }

    /**
     * Stop all currently downloading task
     */
    func stop() {
      for (i, e) in self.finished.enumerate() {
        if !e { self.tasks[i].stop() }
      }
    }

    private func archive(subreddit aSub: Subreddit) {
      let op = TimelineDownloadOperation(aSub)
      ops.append(op)
      this.queue.addOperation(op)
    } 
  }

  // MARK: Operation queue events
  extension DownloadController {
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, contenxt: UnsafeMutablePointer<Void>) {
      if let key = keyPath, let queue = object as NSOperationQueue {

      } 
    }
  }
