//
//  PickerTableViewCell.swift
//  Lottery
//
//  Created by Peter Brooks on 9/28/16.
//  Copyright © 2016 Peter Brooks. All rights reserved.
//

import UIKit

class PickerTableViewCell: UITableViewCell {

    @IBOutlet weak var picker: UIPickerView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func cancel(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(K.cancelNotification), object: nil, userInfo: nil)
    }
    

    @IBAction func save(_ sender: UIButton) {
        
        let info = ["selectedCountry": picker.selectedRow(inComponent: 0),
                    "selectedDivision": picker.selectedRow(inComponent: 1)]
        NotificationCenter.default.post(name: Notification.Name(K.saveNotification), object: nil, userInfo: info)
    }
    
    
}
