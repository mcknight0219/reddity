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
        
    }
}

// MARK: - Tableview data source

extension AccountSwitchViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return account.numberOfAccounts + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AccountSwitchCell", forIndexPath: indexPath) 
        if indexPath.row == account.numberOfAccounts {
            cell.imageView.image = UIImage(named: "plus_sign")
            cell.textLabel.text  = "Add an account"
        } else {
            cell.imageView.image = UIImage(named: "avator")
            var name = account.allUserNames[indexPath.row]
            if name == account.user.name {
                name = name + " ✓"   
            }
            cell.textLabel.text = name
        }   
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    }
}
