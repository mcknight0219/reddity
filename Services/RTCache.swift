//
//  RTCache.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-28.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation

protocol RTCacheDelegate {
    optional func cache(_ cache: RTCache, willEvictObject obj: AnyObject)  
}

/**
 * An in-memory cache that implements the following features:
 * 1. LRU (least-recently-used) 
 * @type {[type]}
 */
class RTCache: NSObject {
    internal struct CacheEntry {
        var 
    }

    public weak var delegate: RTCacheDelegate?

    private var lock: Lock {
        return Lock()
    }

    // Default to evict cache entries by 
    private var evictByCount: Bool = false

    public var name: String = ""
    public var memoryPrintLimit: Int = -1
    public var countLimit: Int = -1

    public override func init() {

    }

    public func setObject(_ obj: anyObject, forKey key: AnyObject, cost g: Int) {
        
    }
}

