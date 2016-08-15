//
//  RTCache.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-28.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation


public protocol RTCacheDelegate: class {
    func cache(cache: RTCache, willEvictObject: AnyObject)
}


/// A LRU cache that could respond to system memory warning
public class RTCache: NSObject {
    class Entry {
        var key: NSObject
        var value: AnyObject
        var prev: Entry?
        var next: Entry?
        var cost: Int = 0
        
        init(key: NSObject, value: AnyObject, cost: Int) {
            self.key = key
            self.value = value
            self.cost = cost
        }
    }
    
    private var _head: Entry?
    private var _tail: Entry?
    private var _entries = [NSObject: Entry]()
    
    private let _lock = NSLock()
    
    /// The number of cached elements
    public var count: Int = 0
    
    /// The name of the cache
    public var name: String = ""
    
    /// Maxium capacity for default cache
    public var maxSizeInMb: Int = 100 {
        didSet {
            self.maxSize = maxSizeInMb * 1024 * 1024
        }
    }
    
    public var maxSize: Int = 100 * 1024 * 1024
    
    public var size: Int = 0
    
    public weak var delegate: RTCacheDelegate?
    
    /**
     Just need to be here to satisfy compiler
     
     */
    override init() {
        super.init()
    }
    
    /**
     Convenient intializer
     
     - parameter name:        the name of the cache
     - parameter maxSizeInMb: maximum size for the cache
     
     */
    convenience init(name: String, maxSizeInMb: Int) {
        self.init()
        self.name = name
        // Default to 100 mb
        self.maxSizeInMb = (maxSizeInMb > 0) ? maxSizeInMb : 100
        self.maxSize = self.maxSizeInMb * 1024 * 1024
    }
    
    // MARK: public interface
    
    public func setObject(obj: AnyObject, forKey key: NSObject, cost: Int) {
        self._lock.lock()
        
        let e = Entry(key: key, value: obj, cost: cost)
        if count == 0 {
            self._head = e
            self._tail = self._head
        } else {
            e.next = self._head
            e.next?.prev = e
            self._head = e
        }
        
        self._entries[key] = e
        self.count = self.count + 1
        self.size = self.size + cost
        
        self._lock.unlock()
        
        //print("[RTCache] set cache for \(key) cost: \(cost)")
        
        self._removeIfNeeded()
    }
    
    public func object(forKey key: NSObject) -> AnyObject? {
        if let e = self._entries[key] {
            // move to most recent use, aka the head
            if e.prev == nil {
                // no need to bump
            } else {
                self._lock.lock()
                
                e.prev?.next = e.next
                if e === self._tail! {
                    self._tail = e.prev
                }
                
                e.next = self._head
                e.next?.prev = e
                self._head = e
                
                self._lock.unlock()
            }
            
            return e.value
        }
        
        return .None
    }
    
    public func removeObject(forKey key: NSObject) {
        if let e = self._entries[key] {
            self._lock.lock()
            
            // If it's first element
            if e.prev == nil {
                self._head = e.next
                if self._head == nil {
                    self._tail = nil
                }
            } else {
                if e === self._tail! {
                    self._tail = e.prev!
                }
                e.prev?.next = e.next
            }
            self.size = self.size - e.cost
            self.count = self.count - 1
            self._entries.removeValueForKey(key)
            
            //print("[RTCache] remove \(key) cost: \(e.cost)")
            
            self._lock.unlock()
        }
    }
    
    public func removeAllObjects() {
        self._entries.removeAll()
        self._head = nil
        self._tail = nil
        
        self.size = 0
        self.count = 0
    }
    
    // MARK: implementation
    
    private func _removeIfNeeded() {
        guard self.size > self.maxSize else { return }
        
        while let tail = self._tail {
            self._tail = tail.prev
            self.removeObject(forKey: tail.key)
            
            if self.size < self.maxSize { break }
        }
    }
}

extension RTCache {
    func printInfo() {
        print("Count = \(self.count) Size = \(self.size) Max = \(self.maxSize)")
        
        var e = self._head
        while e != nil {
            print("\(e!.key) cost: \(e!.cost)")
            
            e = e!.next
        }
    }
}

