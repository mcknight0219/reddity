import Foundation
import Moya
import Reachability
import RxSwift

struct XAppToken {
    enum DefaultsKeys: String {
        case AccessToken = "AccessToken"
        case TokenExpiry = "TokenExpiry"
        case RefreshToken = "RefreshToken"
    }

    let defaults: NSUserDefaults

    init(defaults: NSUserDefaults) {
        self.defaults = defaults
    }

    init() {
        self.defaults = NSUserDefaults.standardUserDefaults()
    }

    var refreshToken: String? {
        get {
            return defaults.stringForKey(DefaultsKeys.RefreshToken.rawValue)
        }
        set(newToken) {
            defaults.setObject(newToken, forKey: DefaultsKeys.RefreshToken.rawValue)
        }
    }

    var accessToken: String? {
        get {
            return defaults.stringForKey(DefaultsKeys.AccessToken.rawValue)
        }
        set(newToken) {
            defaults.setObject(newToken, forKey: DefaultsKeys.AccessToken.rawValue)
        }
    }

    var expiry: NSDate? {
        get {
            return defaults.objectForKey(DefaultsKeys.TokenExpiry.rawValue)
        }
        set(newExpiry) {
            defaults.setObject(newExpiry, forKey: DefaultsKeys.TokenExpiry.rawValue)
        }
    }

    /// excess token expires in 2 hours, we use 119 minutes for caution purpose
    var expired: Bool {
        if let expiry = expiry {
            return expiry.timeIntervalSinceNow > 60 * 119
        }
        return true
    }
}



let reachabilityManager = ReachabilityManager()

func endpointsClosure<T where T: TargetType>()

class MoyaProvider<Target where Target: TargetType>: RxMoyaProvider<Target> {
    private let online: Observable<Bool>

    init() {
        self.online = just(ReachabilityManager.reach)
        super.init(endpointsClosure, requestClosure)
   }

    override func request(action: Target) -> Observable<Moya.response> {
        let actualRequest = super.request(action)
        return online
            .ignore(false)
            .take(1)
            .flatMap { _ in
                return actualRequest
            }
    }
}

struct Networking {
    let provider: OnlineProvider<RedditAPI> 

    func request(action: RedditAPI, defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) -> Observable<Moya.Response> {
        let actualRequest = self.provider.request(action)
        return self.XAppTokenRequest(defaults)
            .flatMap { _ in actualRequest }
    }
}

extension Networking {

    /// Fetch and store new access token if the current token is missing or expired
    private func XAppTokenRequest(defaults: NSUserDefaults) -> Observable<String?> {
        
        var token = XAppToken(defaults: defaults)

        if token.isValid {
            return Observable.just(appToken.accessToken)
        }

        let refreshRequest = self.provider.request(.XApp)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .map { element -> (token: String?, expiry: String?) in
                guard let dict = element as? NSDictionary else { return (token: nil, expiry: nil) }

                return (token: dict["access_token"] as? String, expiry: dict["expires_in"] as? String)
            }
            .doOn { event in
            
            }
            .map { (token, _) -> String? in
                return token
            }
            .logError()

        return refreshRequest
    }
}
