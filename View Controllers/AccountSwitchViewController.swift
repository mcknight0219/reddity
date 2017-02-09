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
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "AccountSwitchCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "AddAccountCell")
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        automaticallyAdjustsScrollViewInsets = false
        
        let px = 1 / UIScreen.mainScreen().scale
        let frame = CGRectMake(0, 0, self.tableView.frame.size.width, px)
        let line = UIView(frame: frame)
        self.tableView.tableHeaderView = line
        line.backgroundColor = self.tableView.separatorColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.contentInset = UIEdgeInsetsMake(33, 0, -33, 0)
    }
}

// MARK: - Tableview data source

extension AccountSwitchViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return account.numberOfAccounts + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == account.numberOfAccounts {
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "AddAccountCell")
            cell.textLabel!.text = "Add an account"
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
            
        } else {
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "AccountSwitchCell")
            cell.imageView!.image = UIImage(named: "avator")
            let name = account.allUserNames[indexPath.row]
            if name == account.user!.name {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
                label.text = "✓"
                label.textColor = UIColor.blueColor()
                label.sizeToFit()
                cell.accessoryView = label
            }
            cell.textLabel!.text = name
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /// Add new account
        if indexPath.row == account.numberOfAccounts {
            self.dismissViewControllerAnimated(true, completion: {
                NSNotificationCenter.defaultCenter().postNotificationName("SignInNotification", object: nil)

            })
        } else {
            let name = account.allUserNames[indexPath.row]
            if name == account.user!.name {
                if let win = (UIApplication.sharedApplication().delegate as! AppDelegate).window {
                    /// shake
                    let animation = CABasicAnimation(keyPath: "position")
                    animation.duration = 0.02
                    animation.repeatCount = 8
                    animation.autoreverses = true
                    animation.fromValue = NSValue(CGPoint: CGPointMake(win.center.x - 8.0, win.center.y))
                    animation.toValue = NSValue(CGPoint: CGPointMake(win.center.x + 8.0, win.center.y))
                    win.layer.addAnimation(animation, forKey: "position")
                }
            } else {
                account.user = AccountType.LoggedInUser(name: name)
                self.dismissViewControllerAnimated(true, completion: {
                   
                })
            }
        }
    }
}
