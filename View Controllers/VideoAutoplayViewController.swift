import UIKit

class VideoAutoplayViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "VideoAutoplayCell")
        self.hideFooter()
        navigationItem.title = "Video auto-play"
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 20))
        view.backgroundColor = UIColor.clearColor()
        
        let sep = UIView(frame: CGRectMake(0, view.frame.size.height-0.5, view.frame.size.width, 0.5))
        sep.backgroundColor = UIColor(colorLiteralRed: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        view.addSubview(sep)
        
        return view
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoAutoplayCell", forIndexPath: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Both cellular and WiFi"
        case 1:
            cell.textLabel?.text = "WiFi only"
        case 2:
            cell.textLabel?.text = "None"
        default:
            break
        }
        
        return cell
    }
}
