//
//  ProfileSectionCell.swift
//  leexplorer
//
//  Created by Hector Monserrate on 25/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import UIKit

class ProfileSectionCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var sectionTextLabel: UILabel!
    
    var title: String! {
        didSet {
            titleLabel.text = title
            titleLabel.textColor = ColorPallete.Black.get()
        }
    }
    
    var sectionText: String! {
        didSet {
            sectionTextLabel.text = sectionText
            sectionTextLabel.textColor = ColorPallete.DarkGrey.get()
        }
    }
    
}
