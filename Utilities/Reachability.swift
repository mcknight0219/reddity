//
//  ReachabilityManager.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-04.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import SystemConfiguration


let kNetworkReachabilityChanged = "NetworkReachabilityChanged"

public enum ReachabilityStatus: Equatable {
    case Unknown
    case NotReachable
    case Reachable(ConnectionType)
}

public enum ConnectionType {
    case WiFi
    case WWAN
}

public func ==(lhs: ReachabilityStatus, rhs: ReachabilityStatus) -> Bool {
    switch (lhs, rhs) {
    case (.Unknown, .Unknown):
        return true
    case (.NotReachable, .NotReachable):
        return true
    case (.Reachable(.WiFi), .Reachable(.WiFi)):
        return true
    case (.Reachable(.WWAN), .Reachable(.WWAN)):
        return true
    default:
        return false
    }
}

public class Reachability {

    public static let sharedInstance = Reachability()
    
    let reachabilityRef: SCNetworkReachabilityRef
        
    var status: ReachabilityStatus {
        get {
            var flags: SCNetworkReachabilityFlags = []
            if SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags) {
                return reachabilityStatusFromFlags(flags)
            }
            return .Unknown
        }
    }
    
    init() {
        var address = sockaddr_in()
        address.sin_len = UInt8(sizeofValue(address))
        address.sin_family = sa_family_t(AF_INET)
        
        self.reachabilityRef = withUnsafePointer(&address, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))!
        })
    }

    deinit {
        stopNotifier()
    }
    
    public func startNotifier() {
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = UnsafeMutablePointer(Unmanaged.passUnretained(self).toOpaque())

        guard SCNetworkReachabilitySetCallback(reachabilityRef, { (_, flags, info) in
            let reachability = Unmanaged<Reachability>.fromOpaque(COpaquePointer(info)).takeUnretainedValue()
            NSNotificationCenter.defaultCenter().postNotificationName(kNetworkReachabilityChanged, object: reachability)
        },
        &context
        ) else { 
            print("failed: SCNetworkReachabilitySetCallback")
            return
        }

        if !SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode) {
            print("failed: SCNetworkReachabilityScheduleWithRunLoop")
        }
    }

    /**
     No need to explicityly call this, it will be called upon desctruction of `defaultManager`, which
     is also the end of app life-cycle.
     */
    public func stopNotifier() {
        SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)
    }
    
    func reachabilityStatusFromFlags(flags: SCNetworkReachabilityFlags) -> ReachabilityStatus {
        guard flags.contains(.Reachable) else { return .NotReachable }
        
        var status: ReachabilityStatus = .NotReachable
        if !flags.contains(.ConnectionRequired) {
            status = .Reachable(.WiFi)
        }
        
        if flags.contains(.ConnectionOnDemand) || flags.contains(.ConnectionOnTraffic) {
            if !flags.contains(.InterventionRequired) {
                status = .Reachable(.WiFi)
            }
        }
        
        if flags.contains(.IsWWAN) {
            status = .Reachable(.WWAN)
        }
        
        return status
    }
}
