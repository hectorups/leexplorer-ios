//
//  GalleryCell.swift
//  leexplorer
//
//  Created by Hector Monserrate on 24/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation


protocol GalleryCellDelegate: class {
    func handleGalleryTab(sender: GalleryCell)
}

class GalleryCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var type: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var infoView: UIView!
    @IBOutlet var icons: [UIImageView]!
    
    weak var delegate: GalleryCellDelegate?

    
    var height: CGFloat!
    
    var gallery: Gallery! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        nameLabel.text = gallery.name
        nameLabel.shadowColor = ColorPallete.Black.get()
        nameLabel.shadowOffset = CGSizeMake(2, 2)
        nameLabel.layer.masksToBounds = false
        
        address.text = gallery.address
        price.text = String(gallery.priceReference)
        type.text = gallery.type
        
        for icon in icons {
            icon.fixTemplateImage()
            icon.tintColor = ColorPallete.White.get()
        }
        
        infoView.backgroundColor = ColorPallete.Black.get().colorWithAlphaComponent(0.35)
        
        setupViewPager()
    }
    
    func setupViewPager() {
        let screenBounds = UIScreen.mainScreen().bounds
        
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        
        for (index, image) in enumerate(gallery.images) {
            let rect = CGRectMake(CGFloat(index) * screenBounds.size.width, 0, screenBounds.size.width, height)
            var imageView = UIImageView(frame: rect)
            var imageUrl = MediaProcessor.urlForImageFill(image as Image, width: Int(bounds.width),
                height: Int(bounds.height), scaleForDevice: true)
            imageView.setImageWithURL(imageUrl)
            imageView.contentMode = .ScaleAspectFill
            imageView.clipsToBounds = true
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSizeMake(screenBounds.size.width * CGFloat(gallery.images.count), height)
        
        setupGesture()
    }
    
    func setupGesture() {
        infoView.userInteractionEnabled = false
        
        var gestureRecognizer = UITapGestureRecognizer(target: self, action: "didTabCell:")
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.numberOfTouchesRequired = 1
        gestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(gestureRecognizer)
    }
    
    func didTabCell(sender: UITapGestureRecognizer) {
        delegate?.handleGalleryTab(self)
    }
    
}