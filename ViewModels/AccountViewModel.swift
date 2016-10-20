import Foundation
import RxSwift
import Moya

protocol AccountViewModelType {
     
}

class AccountViewModel: AccountViewModelType {
    let provider: Networking
    let account: Account

    init(provider: Networking, account: Account) {
        self.provider = provider
        self.account = account
    } 
}
