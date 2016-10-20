import Foundation
import RxSwift
import RxSwiftExt
import Moya
import Alamofire
import ISO8601DateFormatter

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
            return defaults.objectForKey(DefaultsKeys.TokenExpiry.rawValue) as? NSDate
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
    
    var isValid: Bool {
        if let token = accessToken {
            return !token.isEmpty && !expired
        }
        
        return false
    }
}


class OnlineProvider<Target where Target: TargetType>: RxMoyaProvider<Target> {
    private let online: Observable<Bool>

    init(endpointClosure: MoyaProvider<Target>.EndpointClosure = MoyaProvider.DefaultEndpointMapping,
         requestClosure: MoyaProvider<Target>.RequestClosure = MoyaProvider.DefaultRequestMapping,
         stubClosure: MoyaProvider<Target>.StubClosure = MoyaProvider.NeverStub,
         manager: Manager = Alamofire.Manager.sharedInstance,
         plugins: [PluginType] = []) {
        
        self.online = reachabilityManager.reach
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, manager: manager, plugins: [], trackInflights: false)
   }

    override func request(action: Target) -> Observable<Moya.Response> {
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
        // request for refresh token
        switch action {
        case .XApp(grantType: .Code, code: _):
            return actualRequest
        default:
            break
        }
        
        return self.XAppTokenRequest(defaults)
            .flatMap { _ in actualRequest }
    }
}

extension Networking {

    /// Fetch and store new access token if the current token is missing or expired
    private func XAppTokenRequest(defaults: NSUserDefaults) -> Observable<String?> {
        
        var token = XAppToken(defaults: defaults)

        if token.isValid {
            return Observable.just(token.accessToken)
        }

        let refreshRequest = self.provider.request(.XApp(grantType: .Refresh, code: nil))
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .map { element -> (token: String?, expiry: Int?) in
                guard let dict = element as? NSDictionary else { return (token: nil, expiry: nil) }
                return (token: dict["access_token"] as? String, expiry: dict["expires_in"] as? Int)
            }
            .doOn { event in
                guard case Event.Next(let e) = event else { return }
            
                token.accessToken = e.0
                token.expiry = NSDate().dateByAddingTimeInterval(Double(e.1!))
            }
            .map { (token, _) -> String? in
                return token
            }

        return refreshRequest
    }
}

// Static methods
extension Networking {
    
    static func newNetworking() -> Networking {
        return Networking(provider: newProvider())
    }
    
    static func endpointsClosure<T where T: TargetType>(target: T) -> Endpoint<T> {
        let endpoint = Endpoint<T>(URL: url(target), sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
        
        switch target as! RedditAPI {
        case .XApp:
            
            let credential = "oJcxJfNvAUDpOQ:".dataUsingEncoding(NSUTF8StringEncoding)!.base64EncodedStringWithOptions(.Encoding76CharacterLineLength)
            return endpoint.endpointByAddingHTTPHeaderFields(
                ["Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
                 "Authorization": "Basic \(credential)"]
            )
        default:
            return endpoint.endpointByAddingHTTPHeaderFields(["Authorization": "bearer \(XAppToken().accessToken ?? "")", "User-Agent": UIApplication.userAgent()])
        }
    }
}

private func newProvider<T where T: TargetType>() -> OnlineProvider<T> {
    return OnlineProvider(endpointClosure: Networking.endpointsClosure)
}
