//
//  Account.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-23.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation

enum AccountType: String {
    case Guest
    case LoggedInUser(name: String)
}

struct Account {
    enum DefaultsKeys: String {
        case User = "User"
    }

    let defaults: NSUserDefaults

    init(defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
        self.defaults = defaults
    }    

    var user: AccountType? {
        get {
            if let u = defaults.stringForKey(DefaultsKeys.User.rawValue) {
                return u == "guest" ? .Guest : .LoggedInUser(u)
            }

        }
        set(newUser) {
            switch newUser {
            case Guest:
                defaults.setObject("guest", forKey: DefaultsKeys.User.rawValue)
            case LoggedInUser(u):
                defaults.setObject(u, forKey: DefaultsKeys.User.rawValue)
            }
        }
    }

    var isPristine: Bool {
        return self.user == nil
    }

    var isGuest: Bool {
        if let u = user {
            switch u {
            case .Guest:
                return true
            default:
                return false
            }
        }
        return false
    }
}
