import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

class AccountSwitchViewController: BaseTableViewController {

    lazy var account: Account = {
        return Account()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideFooter()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AccountSwitchCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AddAccountCell")
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        automaticallyAdjustsScrollViewInsets = false
        
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: px)
        let line = UIView(frame: frame)
        self.tableView.tableHeaderView = line
        line.backgroundColor = self.tableView.separatorColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.contentInset = UIEdgeInsetsMake(33, 0, -33, 0)
    }
}

// MARK: - Tableview data source

extension AccountSwitchViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return account.numberOfAccounts + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == account.numberOfAccounts {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "AddAccountCell")
            cell.textLabel!.text = "Add an account"
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
            
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "AccountSwitchCell")
            cell.imageView!.image = UIImage(named: "avator")
            let name = account.allUserNames[indexPath.row]
            if name == account.user!.name {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
                label.text = "✓"
                label.textColor = UIColor.blue
                label.sizeToFit()
                cell.accessoryView = label
            }
            cell.textLabel!.text = name
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// Add new account
        if indexPath.row == account.numberOfAccounts {
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name.onSignIn, object: nil)

            })
        } else {
            let name = account.allUserNames[indexPath.row]
            if name == account.user!.name {
                if let win = (UIApplication.shared.delegate as! AppDelegate).window {
                    /// shake
                    let animation = CABasicAnimation(keyPath: "position")
                    animation.duration = 0.02
                    animation.repeatCount = 8
                    animation.autoreverses = true
                    animation.fromValue = NSValue(cgPoint: CGPoint(x: win.center.x - 8.0, y: win.center.y))
                    animation.toValue = NSValue(cgPoint: CGPoint(x: win.center.x + 8.0, y: win.center.y))
                    win.layer.add(animation, forKey: "position")
                }
            } else {
                account.user = AccountType.LoggedInUser(name: name)
                self.dismiss(animated: true, completion: {
                   
                })
            }
        }
    }
}
