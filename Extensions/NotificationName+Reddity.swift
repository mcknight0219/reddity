//
//  NotificationName+Reddity.swift
//  Reddity
//
//  Created by Qiang Guo on 2017/2/11.
//  Copyright © 2017年 Qiang Guo. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let onOAuthFinished = Notification.Name("oauth-finished")
    static let onAfterStartup = Notification.Name("after-startup")
    static let onSaveTimeline = Notification.Name("save-timeline")
    static let onSignIn = Notification.Name("sign-in")
    // kThemeManagerDidChangeThemeNotification
    static let onThemeChanged = Notification.Name("theme-changed")
}
