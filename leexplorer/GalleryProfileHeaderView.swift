//
//  GalleryProfileHeader.swift
//  leexplorer
//
//  Created by Hector Monserrate on 25/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import UIKit
import QuartzCore

class GalleryProfileHeaderView: NibDesignable {

    @IBOutlet var blurredImageView: UIImageView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var icons: [UIImageView]!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var languagesLabel: UILabel!
    @IBOutlet var infoView: GradientView!
    @IBOutlet var infoViewBottomConstraint: NSLayoutConstraint!
    
    let BLUR_RADIUS: CGFloat = 160.0
    
    var gradient: CAGradientLayer?
    
    var gallery: Gallery! {
        didSet {
            updateUI()
        }
    }
    
    
    func updateUI() {
        
        let imageModel = gallery.images.firstObject() as! Image
        imageView.setImageWithImageModel(imageModel, width: Int(bounds.width), height: Int(bounds.height)
            , galleryId: gallery.id) { (image) -> Void in
                self.imageView.image = image
                self.blurredImageView.setImageToBlur(image, blurRadius: 8.0, completionBlock: nil)
        }
        
        addressLabel.text = gallery.address
        typeLabel.text = gallery.type
        languagesLabel.text = ", ".join(gallery.getLanguages())
        
        for icon in icons {
            icon.fixTemplateImage()
            icon.tintColor = ColorPallete.White.get()
        }
        
        setupGradient()
    }
    
    func setupGradient() {
        var layer = infoView.layer as! CAGradientLayer
        layer.opacity = 0.8
        let colors: [AnyObject] = [ColorPallete.Black.get().CGColor!, ColorPallete.Clear.get().CGColor!]
        layer.colors = colors
        layer.startPoint = CGPoint(x: 0.0, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 0.5)
    }
    
    func blur(offset: CGFloat, headerHeight: CGFloat) {
        if offset < 0 {
            frame.size.height = headerHeight + -1 * offset
            center.y = (frame.size.height / 2)
            
            var alpha: CGFloat = 0.0
            
            if offset > BLUR_RADIUS * -1 {
                alpha = (BLUR_RADIUS + offset) / BLUR_RADIUS;
            }
            
            imageView.alpha = alpha;
            
            infoViewBottomConstraint.constant = frame.size.height - headerHeight
        } else if offset > 0 {
            center.y = (headerHeight / 2) - offset
        }
    }
    
}
