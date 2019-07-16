//
//  NotesTableViewCell.swift
//  ToDoS
//
//  Created by iglo on 16/07/19.
//  Copyright © 2019 iglo. All rights reserved.
//

import UIKit

class NotesTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
