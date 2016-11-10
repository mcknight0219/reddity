//
//  Account.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-06-23.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation

enum AccountType {
    case Guest
    case LoggedInUser(name: String)

    var name: String {
        switch self {
        case Guest:
            return "guest"
        case LoggedInUser(let name):
            return name
        }
    }
}

struct Account {
    enum DefaultsKeys: String {
        case User = "User"
        case Pool = "UserPool"
    }

    let defaults: NSUserDefaults

    init(defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
        self.defaults = defaults
    }    

    var user: AccountType? {
        get {
            if let u = defaults.stringForKey(DefaultsKeys.User.rawValue) {
                if u == "guest" {
                    return .Guest
                } else {
                    return .LoggedInUser(name: u)
                }
            }
            return nil
        }
        set(newUser) {
            switch newUser! {
            case .Guest:
                defaults.setObject("guest", forKey: DefaultsKeys.User.rawValue)
            case .LoggedInUser(let u):
                defaults.setObject(u, forKey: DefaultsKeys.User.rawValue)
                self.rememberMe()
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
    var numberOfAccounts: Int {
        guard let pool = defaults.dictionaryForKey(DefaultsKeys.Pool.rawValue) else {
            return 0
        } 
        return pool.count
    }

    var allUserNames: [String] {
        guar let pool = defaults.dictionaryForKey(DefaultsKeys.Pool.rawValue) else {
            return []
        }
        return pool.keys()
    }
}

extension Account {
    func forget() {
        defaults.removeObjectForKey(DefaultsKeys.User.rawValue)
    }

    // Store the refresh token for currently logged in User
    // in case user want to switch account while browsing
    func remeberMe(name: String) {
        guard let pool = defaults.dictionaryForKey(DefaultsKeys.Pool.rawValue) else {
            pool = [String: AnyObject]()
        }

        pool[name] = XApp().refreshToken

        defaults.setDictionary(pool, forKey: DefaultsKeys.Pool.rawValue)
    }
}
