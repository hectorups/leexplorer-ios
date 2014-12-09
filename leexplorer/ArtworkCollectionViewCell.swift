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
    @IBOutlet weak var signalImageView: UIImageView!
    @IBOutlet weak var accuracyLabel: UILabel!
    
    var accuracy: Double? {
        didSet {
            signalImageView.hidden = accuracy == nil
            accuracyLabel.hidden = accuracy == nil
            
            if let value = accuracy {
                let format = "%.2f"
                accuracyLabel.text = "\(NSString(format: format, value))"
            }
            
            if !AppConstant.DEBUG {
                accuracyLabel.hidden = true
            }
        }
    }
    
    var artwork: Artwork! {
        didSet {
            imageView.setImageWithImageModel(artwork.image, width: Int(bounds.width), height: Int(bounds.height),
                galleryId: artwork.galleryId)
            
            infoView.backgroundColor = ColorPallete.Black.get().colorWithAlphaComponent(0.35)
            
            authorNameLabel.text = artwork.author
            artworkNameLabel.text = artwork.name
            
            if let publishedAt = artwork.publishedAt() {
                dateLabel.text = NSDateFormatter.leShared.stringFromDate(publishedAt)
            } else {
                dateLabel.hidden = true
                separatorLabel.hidden = true
            }
            signalImageView.hidden = true
            setupSignal()
        }
    }
    
    func setupSignal() {
        var animationImages = [UIImage]()
        for index in (1...4) {
            animationImages.append(UIImage(named: "ble\(index)")!)
        }
        
        signalImageView.animationImages = animationImages
        signalImageView.animationDuration = 0.9
        signalImageView.animationRepeatCount = 0
        startAnimating()
    }
    
    func startAnimating() {
        signalImageView.startAnimating()
    }
    
}
