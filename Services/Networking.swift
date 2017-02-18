import Foundation
import RxSwift
import RxSwiftExt
import Moya
import Alamofire

struct XAppToken {
    enum DefaultsKeys: String {
        case AccessToken = "AccessToken"
        case TokenExpiry = "TokenExpiry"
        case RefreshToken = "RefreshToken"
    }

    let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    init() {
        self.defaults = UserDefaults.standard
    }

    var refreshToken: String? {
        get {
            return defaults.string(forKey: DefaultsKeys.RefreshToken.rawValue)
        }
        set(newToken) {
            defaults.set(newToken, forKey: DefaultsKeys.RefreshToken.rawValue)
        }
    }

    var accessToken: String? {
        get {
            return defaults.string(forKey: DefaultsKeys.AccessToken.rawValue)
        }
        set(newToken) {
            defaults.set(newToken, forKey: DefaultsKeys.AccessToken.rawValue)
        }
    }

    var expiry: NSDate? {
        get {
            return defaults.object(forKey: DefaultsKeys.TokenExpiry.rawValue) as? NSDate
        }
        set(newExpiry) {
            defaults.set(newExpiry, forKey: DefaultsKeys.TokenExpiry.rawValue)
        }
    }

    /// excess token expires in 2 hours, we use 119 minutes for caution purpose
    var expired: Bool {
        if let expiry = expiry {
            return expiry.compare(NSDate() as Date) == .orderedAscending
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


class OnlineProvider<Target>: RxMoyaProvider<Target> where Target: TargetType {
    private let online: Observable<Bool>

    init(endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider.defaultEndpointMapping,
         requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider.defaultRequestMapping,
         stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
         manager: Manager = MoyaProvider<Target>.defaultAlamofireManager(),
         plugins: [PluginType] = []) {
        self.online = reachabilityManager.reach
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, manager: manager, plugins: [], trackInflights: false)
   }

    override func request(_ action: Target) -> Observable<Moya.Response> {
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

    func request(action: RedditAPI, defaults: UserDefaults = UserDefaults.standard) -> Observable<Moya.Response> {
        let actualRequest = self.provider.request(action)
        // request for refresh token
        switch action {
        case .XApp(grantType: .Code, code: _):
            return actualRequest
        default:
            break
        }
        
        return self.XAppTokenRequest(defaults: defaults)
            .flatMap { _ in actualRequest }
    }
}

extension Networking {

    /// Fetch and store new access token if the current token is missing or expired
    fileprivate func XAppTokenRequest(defaults: UserDefaults) -> Observable<String?> {
        
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
            .do(onNext: { pair in
                token.accessToken = pair.0
                token.expiry = NSDate().addingTimeInterval(Double(pair.1!))
            })
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
    
    static func endpointsClosure<T>(target: T) -> Endpoint<T> where T: TargetType {
        let endpoint = Endpoint<T>(url: url(route: target), sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
        
        switch target as! RedditAPI {
        case .XApp:
            
            let credential = "oJcxJfNvAUDpOQ:".data(using: String.Encoding.utf8)!.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength76Characters)
            return endpoint.adding(
                newHTTPHeaderFields: ["Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
                 "Authorization": "Basic \(credential)"]
            )
        default:
            return endpoint.adding(newHTTPHeaderFields: ["Authorization": "bearer \(XAppToken().accessToken ?? "")", "User-Agent": UIApplication.userAgent()])
        }
    }
}

private func newProvider<T>() -> OnlineProvider<T> where T: TargetType {
    return OnlineProvider(endpointClosure: Networking.endpointsClosure)
}
