//
//  MenuTableViewController.swift
//  ToDoS
//
//  Created by iglo on 16/07/19.
//  Copyright © 2019 iglo. All rights reserved.
//

import UIKit


class MenuTableViewController: UITableViewController {
    
    var didTapMenuType : ((MenuType) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuType = MenuType(rawValue: indexPath.row - 1) else { return}
        dismiss(animated: true) { [weak self] in
            print("dismiss : \(menuType)")
            self?.didTapMenuType?(menuType)
        }
    }

}
