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
    
    class func heightWithText(text: String) -> CGFloat {
        let nsText = NSString(string: text)
        
        let font = UIFont.systemFontOfSize(18.0)
        let screenSize = UIScreen.mainScreen().bounds.size
        let width = screenSize.width - 16
        let labelRect = nsText.boundingRectWithSize(CGSizeMake(CGFloat(width), CGFloat(MAXFLOAT)),
            options: .UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: font],
            context: nil)
        
        return labelRect.size.height + 27 + 28
    }
    
}
