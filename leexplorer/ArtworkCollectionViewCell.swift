//
//  ArtworkCollectionViewCell.swift
//  leexplorer
//
//  Created by Hector Monserrate on 26/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import UIKit

class ArtworkCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var infoView: UIView!
    @IBOutlet var authorNameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var artworkNameLabel: UILabel!
    @IBOutlet var separatorLabel: UILabel!
    
    
    
    var artwork: Artwork! {
        didSet {
            var imageUrl = MediaProcessor.urlForImageFill(artwork.image,
                width: Int(bounds.width), height: Int(bounds.height))
            
            imageView.setImageWithURL(imageUrl)
            
            infoView.backgroundColor = ColorPallete.Black.get().colorWithAlphaComponent(0.35)
            
            authorNameLabel.text = artwork.author
            artworkNameLabel.text = artwork.name
            
            if let publishedAt = artwork.publishedAt {
                dateLabel.text = NSDateFormatter.leShared.stringFromDate(publishedAt)
            } else {
                dateLabel.hidden = true
                separatorLabel.hidden = true
            }
        }
    }
    
    
}
