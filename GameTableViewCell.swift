//
//  GameTableViewCell.swift
//  Lottery
//
//  Created by Peter Brooks on 9/5/16.
//  Copyright © 2016 Peter Brooks. All rights reserved.
//

import UIKit

class GameTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var gameValue: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code not needed
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
