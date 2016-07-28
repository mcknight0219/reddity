//
//  TokenService.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-07-02.
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import Foundation
import SwiftyJSON

enum TokenType: String, CustomStringConvertible {
    case Bearer = "bearer"
    
    var description: String {
        return self.rawValue
    }
}

enum GrantType: String, CustomStringConvertible {
    case Code       = "authorization_code" // for user auth
    case Installed  = "https://oauth.reddit.com/grants/installed_client"     // For user context-less auth
    
    var description: String {
        return self.rawValue
    }
}

final class TokenService {
    static let sharedInstance = TokenService()
    
    let CodeTokenCacheKey = "CodeTokenCacheKey"
    let InstalledTokenCacheKey = "InstalledTokenCacheKey"
    let TokenExpireTimeCacheKey = "TokenExpireTimeCacheKey"
    
    let cache = NSCache()
    
    var code: String? {
        didSet {
            self.grantType = .Code
        }
    }
    
    var grantType: GrantType = .Installed
    
    var token: String {
        didSet {
            if let timer = self.timer {
                timer.invalidate()
            }
            
            timer = NSTimer.scheduledTimerWithTimeInterval(60 * 59 + 58 , target: self, selector: #selector(TokenService.refresh), userInfo: nil, repeats: true)
        }
    }
    
    var timer: NSTimer?
    
    init() {
        self.token = ""
    }
    
    func basicAuthHeaderString() -> String {
        let userPasswordString = "oJcxJfNvAUDpOQ:"
        let userPasswordData = userPasswordString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedCredential = userPasswordData?.base64EncodedStringWithOptions(.Encoding76CharacterLineLength)
        
        return "Basic \(base64EncodedCredential!)"
    }
    
    func withAccessToken(completion: () -> Void) {
        //let key = self.grantType == .Code ? CodeTokenCacheKey : InstalledTokenCacheKey
        if !self.token.isEmpty {
            completion()
            return
        }
        
        // Just use refresh token to request an access token
        if let refreshToken = NSUserDefaults.standardUserDefaults().objectForKey("RefreshToken") as? String {
            self.cache.setObject(refreshToken, forKey: "RefreshToken")
            self.refresh()
            completion()
            return
        }
        
        
        let requestBody: () -> String = {
            var body = "grant_type=\(self.grantType.rawValue)"
            if let code = self.code {
                body.appendContentsOf("&code=\(code)&redirect_uri=reddity://response")
            } else {
                body.appendContentsOf("&device_id=\(NSUUID().UUIDString)")
            }
            
            return body
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.reddit.com/api/v1/access_token")!)
        request.HTTPMethod = "POST"
        request.HTTPBody = requestBody().dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue(basicAuthHeaderString(), forHTTPHeaderField: "Authorization")
        
        let (data, response, _) = NSURLSession.sharedSession().synchronousDataTaskWithURL(request)
        if let data = data, response = response as? NSHTTPURLResponse {
            if response.statusCode == 401 {
                print("401 response when requesting token")
                // toast
            } else {
                let json = JSON(data: data)
                let refreshToken = json["refresh_token"].stringValue
                self.token = json["access_token"].stringValue
                if !refreshToken.isEmpty {
                    NSUserDefaults.standardUserDefaults().setObject(refreshToken, forKey: "RefreshToken")
                    self.cache.setObject(refreshToken, forKey: "RefreshToken")
                }
                
                completion()
            }
        }
    }
    
    @objc func refresh() {
        let refreshToken = self.cache.objectForKey("RefreshToken") as! String
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.reddit.com/api/v1/access_token")!)
        request.HTTPMethod = "POST"
        request.HTTPBody = "grant_type=refresh_token&refresh_token=\(refreshToken)".dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue(basicAuthHeaderString(), forHTTPHeaderField: "Authorization")
        
        let (data, response, _) = NSURLSession.sharedSession().synchronousDataTaskWithURL(request)
        if let data = data, let response = response as? NSHTTPURLResponse {
            if response.statusCode == 401 {
                print("401 response when refreshing access token")
                // toast
            } else {
                let json = JSON(data: data)
                self.token = json["access_token"].stringValue
                
                print("update refresh token")
            }
        }
    }
}