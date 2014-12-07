//
//  ArtworkProfileHeaderView.swift
//  leexplorer
//
//  Created by Hector Monserrate on 26/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

class ArtworkProfileHeaderView: NibDesignable {
    
    @IBOutlet var blurredImageView: UIImageView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var infoView: UIView!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var separatorLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    let BLUR_RADIUS: CGFloat = 150.0
    
    var artwork: Artwork! {
        didSet {
            setupUI()
        }
    }
    
    func setupUI() {
        var imageUrl = MediaProcessor.urlForImageFill(artwork.image,
            width: Int(bounds.width), height: Int(bounds.height))
        
        imageView.setImageWithURLRequest(NSURLRequest(URL: imageUrl), placeholderImage: nil
            , success: { (request, response, image) -> Void in
                self.imageView.image = image
                self.blurredImageView.setImageToBlur(image, blurRadius: 8.0, completionBlock: nil)
            }, failure: nil)
        
        authorLabel.text = artwork.author
        if let publishedAt = artwork.publishedAt {
            dateLabel.text = NSDateFormatter.leShared.stringFromDate(publishedAt)
        } else {
            dateLabel.hidden = true
            separatorLabel.hidden = true
        }
        
        infoView.backgroundColor = ColorPallete.Black.get().colorWithAlphaComponent(0.35)
    }
    
    func blur(offset: CGFloat, headerHeight: CGFloat) {
        let maxHeaderScroll = headerHeight - infoView.frame.height
        
        if offset < 0 {
            frame.size.height = headerHeight + -1 * offset
            center.y = (frame.size.height / 2)
            
            var alpha: CGFloat = 0.0
            
            if offset > BLUR_RADIUS * -1 {
                alpha = (BLUR_RADIUS + offset) / BLUR_RADIUS;
            }
            
            imageView.alpha = alpha
            infoView.alpha = max(0, CGFloat(alpha * 0.8))
            
        } else if offset > 0 {
            center.y = (headerHeight / 2) - min(offset, maxHeaderScroll)
        }
        
        if offset >= 0 {
            infoView.alpha = 1
        }
    }
    
}