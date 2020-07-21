//
//  DetailsPageTableViewCell.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/21/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit

class DetailsPageTableViewCell: UITableViewCell {

    static let identifier = "DetailsPageTableViewCell"
    
    @IBOutlet var cellView: UIView!
    @IBOutlet var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
