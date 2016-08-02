//
//  MeViewController.swift
//  Reddity
//
//  Created by Qiang Guo on 2016-08-02
//  Copyright © 2016 Qiang Guo. All rights reserved.
//

import UIKit
import SwiftyJSON
import SnapKit

class MeViewController: UITableViewController {

  override func viewDidLoad() {
  
  }

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return 4
  }

  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return 64
  }

  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      let view = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 64))
      let label = UILabel()
      view.addSubview(label)
      label.snp_makeConstraints { (make) -> Void in
        make.leading.trailing.bottom.equalTo(view)
        make.height.equalTo(32)
      }
      label.textColor = FlatGray()
      
      switch section {
          
      }
      
  }

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return 44
  }
}
