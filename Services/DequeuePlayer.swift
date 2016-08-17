//
//  DequeuePlayer.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-07.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import AVFoundation

/**
 The direction player proceeds with its queue.
 */
enum PlaybackDirection {
    case Forward
    case Backward
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
     Initializes an instance of DequeuePlayer by enqueueing the player items from a given array.

     @param items An array of `AVPlayerItem` objects with which initially to populate the player's queue.
     */
    init(items items: [AVPlayerItem]) {

    }

    /**
     Returns an array of the currently enqueued items.

     @return An array of the currently enqueued items.
     */
    func items() -> [AVPlayerItem] {

    }

    /**
     Returns a Boolean value that indicates whether a given player item can be inserted into the player's queue.

     @discussion Adding the same item to a player at more than one position in the queue is not supported.

     @param item The `AVPlayerItem` object to test.
     @param afterItem The item that `item` is to follow in the queue. Pass nil to test whether `item`
     can be appended to the queue.
     @return `true` if item can be appended to the queue, otherwise `false`.
     */
    func canInsertItem(_ item: AVPlayerItem, afterItem afterItem: AVPlayerItem?) -> Bool {
        
    }

    /**
     Places given player item after a specified item in the queue.

     @param item The item to be inserted
     @param afterItem THe item that the newly inserted item should follow in the queue. Pass nil to append
     the item to the queue.
     */
    func insertItem(_ item: AVPlayerItem, afterItem afterItem: AVPlayerItem?) {
        
    }

    /**
     Removes a given player item from the queue.

     @discussion If `item` is currently playing, this has the same effect as `advanceToNextItem`

     @param item The item to be removed.
     */
    func removeItem(_ item: AVPlayerItem) {
        
    }

    /**
     Removes all the items from the queue.

     @discussion This has the side-effect of stopping playback by the player
     */
    func removeAllItems() {
        
    }

    /**
     Ends playback of the current item and initiates playback of the next item in the play queue.

     @discussion This method doesn't remove current item from the playqueue. It simply procceds to 
     next item if there is one available. 
     If it's already the last item, this has no effect to the player.
     */
    func advanceToNextItem() {

    }
}
