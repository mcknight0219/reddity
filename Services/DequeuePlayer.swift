//
//  DequeuePlayer.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-07.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation
import AVFoundation

/**
 The direction player proceeds with its queue.
 */
enum PlaybackDirection {
    case Forward
    case Backward
}

struct PlaybackOptions: OptionSetType {
    let rawValue: Int

    static let repeatOne = PlaybackOptions(rawValue: 1 << 0)
    static let repeatAll = PlaybackOptions(rawValue: 1 << 1)
}

/**
 A subclass of `AVPlayer` that supports playback in either forward and backward direction

 @discussion The api and behabior are similar to AVQueuePlayer. And it offers following features:

 * It manages the playback queue without removing items so that it could play previously items. 
 * It loads assets asynchronously so not to block thread.

 */
class DequeuePlayer: AVPlayer {
    
    /**
     The direction player proceeds on its queue.

     @discussion Setting this property will affect `advanceToNextItem` and queue management functions
     */
    var playbackDirection: PlaybackDirection = .Forward

    /**
     An array of `AVPlayerItem` that player uses for playback
     */
    private var playbackQueue = [AVPlayerItem]()

    /**
     The index in `playbackQueue` of currently playing item
     */
    private var currentPlayerItemIndex: Int = 0

    /**
     The lock for threadsafety
     */
    private let mutex = NSLock()

    /**
     Maximum number of player item the player could hold.

     @discussion When maximum is reached, an item at the far end of the queue is removed to make place
     for the new one.
     */
    let MaxPlaybackQueueItems = 30

    /**
     The playback options
     */
    private let options: PlaybackOptions

    /**
     Initializes an instance of DequeuePlayer by enqueueing the player items from a given array.

     @param items An array of `AVPlayerItem` objects with which initially to populate the player's queue.
     @param options Specify players behavior
     */
    init(items: [AVPlayerItem], options: PlaybackOptions?) {
        super.init()
        playbackQueue.reserveCapacity(MaxPlaybackQueueItems)
        playbackQueue += items[0..<(items.count > MaxPlaybackQueueItems ? MaxPlaybackQueueItems : items.count)]

        self.options = options == nil ? .default : options
        if self.options.contains(.repeatOne) {
            actionAtItemEnd = .None
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DequeuePlayer.repeatTrack(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        }
        
        replaceCurrentItemWithPlayerItem(playbackQueue.first)
    }

    /**
     Initializes an instnace of DequeuePlayer by enqueueing the player items created from urls
     from a given array.

     @param urls An array of `NSURL` objects with which initially to populate the player's queue.
     */
    convenience init(urls: [NSURL], options: PlaybackOptions) {
        let items = urls.flatMap { AVPlayerItem(asset: AVURLAsset(URL: $0, options: nil)) }
        self.init(items: items, options: options)
    }

    deinit {
        if self.options.contains(.repeatOne) {
            NSNotificationCenter.defaultCenter().removeObserver(self, AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        }
    }

    /**
     Returns an array of the currently enqueued items.

     @return An array of the currently enqueued items.
     */
    func items() -> [AVPlayerItem] {
        return self.playbackQueue
    }
    
    override func play() {
        let asset = playbackQueue[currentPlayerItemIndex].asset
        asset.loadValuesAsynchronouslyForKeys(["tracks"]) {
            super.play()
        }
    }

    /**
     Returns a Boolean value that indicates whether a given player item can be inserted into the player's queue.

     @discussion Adding the same item to a player at more than one position in the queue is not supported.

     @param item The `AVPlayerItem` object to test.
     @param afterItem The item that `item` is to follow in the queue. Pass nil to test whether `item`
     can be appended to the queue.
     @return `true` if item can be appended to the queue, otherwise `false`.
     */
    func canInsertItem(item: AVPlayerItem, afterItem: AVPlayerItem?) -> Bool {
        guard self.playbackQueue.count <= self.MaxPlaybackQueueItems else { return false }

        var sentinel: AVPlayerItem?
        for i in self.playbackQueue {
            if item == i { return false }
            if i == afterItem { sentinel = i }
        }  

        return afterItem == nil ? true : (sentinel == nil ? true: false)
    }

    /**
     Places given player item after a specified item in the queue.

     @param item The item to be inserted
     @param afterItem THe item that the newly inserted item should follow in the queue. Pass nil to append
     the item to the queue.
     */
    func insertItem(item: AVPlayerItem, afterItem: AVPlayerItem?) {
        guard canInsertItem(item, afterItem) else { return }

        // Remove the item at the other end because it's probably the LRU item
        if playbackQueue.count == MaxPlaybackQueueItems {
            if currentPlayerItemIndex > count / 2 {
                playbackQueue.removeAtIndex(0)
            } else {
                playbackQueue.removeLast()
            }
        }

        var sentinel: AVPlayerItem?
        if let afterItem = afterItem {
            sentinel = afterItem
        } else {
            sentinel = playbackQueue.last
        }

        playbackQueue.insert(item, at: self.playbackQueue.indexOf(sentinel) + 1)
    }

    /**
     Removes a given player item from the queue.

     @discussion If `item` is currently playing, this has the same effect as `advanceToNextItem`

     @param item The item to be removed.
     */
    func removeItem(item: AVPlayerItem) {
        if let playing = playbackQueue[currentPlayerItemIndex] {
            if item == playing { advanceToNexItem() }
        }
        
        playbackQueue.remove(item)
    }

    /**
     Removes all the items from the queue.

     @discussion This has the side-effect of stopping playback by the player
     */
    func removeAllItems() {
        self.pause()
        self.replaceCurrentItemWithPlayerItem(item: nil)

        playbackQueue.removeAll()
    }

    /**
     Ends playback of the current item and initiates playback of the next item in the play queue.

     @discussion This method doesn't remove current item from the playqueue. It simply procceds to 
     next item if there is one available. 
     If it's already the last item, this has no effect to the player.
     */
    func advanceToNextItem() {
        pause()
        if currentPlayerItemIndex + 1 == count && !self.options.contains(.repeatAll) {
            return
        }
        
        currentPlayerItemIndex = (currentPlayerItemIndex + 1) % count
        self.replaceCurrentItemWithPlayerItem(playbackQueue[currentPlayerItemIndex])
        
        play()
    }

    /**
     Ends playback of the current item and initiates playback of the previous item in the play queue.

     @discussion This method doesn't remove current item from the playqueue. It backs to previous item
     if there is one available.
     If it's the first item, this has to effect to the player.
     */
    func backToPrevItem() {
        pause()
        if currentPlayerItemIndex == 0 && !self.options.contains(.repeatAll) {
            return
        }
        currentPlayerItemIndex = (currentPlayerItemIndex - 1 + count) % count
        self.replaceCurrentItemWithPlayerItem(playbackQueue[currentPlayerItemIndex])
        play()
    }

    /**
     Repeat the current item if there is any.  
     */
    internal func repeatTrack() {
        if let item = self.currentItem {
            item.seekToTime(kCMTimeZero)
        } 
    }
}
