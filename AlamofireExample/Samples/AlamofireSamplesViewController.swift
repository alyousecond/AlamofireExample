//
//  SamplesTableViewController.swift
//  AlamofireExample
//
//  Created by Yuji Sugaya on 2018/06/19.
//  Copyright © 2018年 Yuji Sugaya. All rights reserved.
//

import UIKit

class AlamofireSamplesViewController: UITableViewController {
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let vc = AppBuilder().buildListView()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
