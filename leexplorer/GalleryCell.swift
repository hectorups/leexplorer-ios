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

class GalleryCell: UITableViewCell, SwipeViewDataSource, SwipeViewDelegate {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var type: UILabel!
    @IBOutlet var infoView: UIView!
    @IBOutlet var icons: [UIImageView]!
    @IBOutlet weak var swipeView: SwipeView!
    
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
        swipeView.delegate = self
        swipeView.dataSource = self
        swipeView.reloadData()
    }
    
    // MARK: - SwipView Delegates
    
    func swipeView(swipeView: SwipeView!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        let screenBounds = UIScreen.mainScreen().bounds
        let image = gallery.images[UInt(index)] as Image
        if view == nil || view.tag != index{
            let rect = CGRectMake(CGFloat(index) * screenBounds.size.width, 0, screenBounds.size.width, height)
            var imageView = UIImageView(frame: rect)
            imageView.setImageWithImageModel(image as Image, width: Int(bounds.width),
                height: Int(bounds.height), galleryId: gallery.id)

            imageView.contentMode = .ScaleAspectFill
            imageView.clipsToBounds = true
            imageView.tag = index
            return imageView
        }
        
        return view
    }

    func numberOfItemsInSwipeView(swipeView: SwipeView!) -> Int {
        return Int(gallery.images.count)
    }
    
    func swipeView(swipeView: SwipeView!, didSelectItemAtIndex index: Int) {
        delegate?.handleGalleryTab(self)
    }
    
}