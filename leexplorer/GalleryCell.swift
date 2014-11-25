//
//  GalleryCell.swift
//  leexplorer
//
//  Created by Hector Monserrate on 24/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

class GalleryCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    
    var gallery: String! {
        didSet {
            nameLabel.text = gallery
        }
    }
    
}