import UIKit

class VideoAutoplayViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VideoAutoplayCell")
        self.hideFooter()
        navigationItem.title = "Video auto-play"
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20))
        view.backgroundColor = UIColor.clear
        
        let sep = UIView(frame: CGRect(x: 0, y: view.frame.size.height-0.5, width: view.frame.size.width, height: 0.5))
        sep.backgroundColor = UIColor(colorLiteralRed: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        view.addSubview(sep)
        
        return view
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoAutoplayCell", for: indexPath)
        
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
