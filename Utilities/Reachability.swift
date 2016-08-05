//
//  Reachability.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-04.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import SystemConfiguration

/*
 The network reachability manager class notifies about changes of networking
 condition. Call startMonitoring() when app starts and then rest of the app
 could access the reachability by checking status ivar
*/
public class ReachabilityManager {
    
    public static var sharedInstance = ReachabilityManager()
    
    public enum ReachabilityStatus {
        case Unknown
        case NotReachable
        case Reachable(ConnectionType)
    }
    
    public enum ConnectionType {
        case WiFi
        case WWAN
    }
    
    let reachability: SCNetworkReachabilityRef
    var flags = SCNetworkReachabilityFlags() {
        didSet {
            status = self.reachabilityStatusFromFlags(flags)
        }
    }
    
    var status: ReachabilityStatus = .Unknown
    
    lazy var sharedQueue: dispatch_queue_t = {
        dispatch_queue_create("reddity.reachability", DISPATCH_QUEUE_SERIAL)
    }()
    
    private init?() {
        var address = sockaddr_in()
        address.sin_len = UInt8(sizeofValue(address))
        address.sin_family = sa_family_t(AF_INET)
        
        guard let reachability = withUnsafePointer(&address, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else { return nil }
        
        self.reachability = reachability
    }
    
    public func startMonitoring() {
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = UnsafeMutablePointer(Unmanaged.passUnretained(self).toOpaque())
        
        SCNetworkReachabilitySetCallback(reachability, { (_, flags, info) in
            let reachability = Unmanaged<ReachabilityManager>.fromOpaque(COpaquePointer(info)).takeUnretainedValue()
            reachability.flags = flags
            },
                                         &context
        )
        
        SCNetworkReachabilitySetDispatchQueue(reachability, sharedQueue)
        
        var flags: SCNetworkReachabilityFlags = []
        if SCNetworkReachabilityGetFlags(self.reachability, &flags) {
            self.flags = flags
        }
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
    
    public func connected() -> Bool {
        switch self.status {
        case .NotReachable:
            return false
        case .Unknown:
            return false
        case .Reachable(_):
            return true
        }
    }
}