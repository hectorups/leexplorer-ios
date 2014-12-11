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
    @IBOutlet weak var playIndicator: UIImageView!
    
    enum AudioStatus {
        case Playing, Paused, NotPlaying
    }
    
    
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
    
    var status: AudioStatus = .NotPlaying {
        didSet {
            switch status {
            case .NotPlaying:
                playIndicator.hidden = true
                return
            case .Playing:
                playIndicator.image = UIImage(named: "play_icon")
            case .Paused:
                playIndicator.image = UIImage(named: "pause_icon")
            }
            
            playIndicator.fixTemplateImage()
            playIndicator.tintColor = ColorPallete.White.get()
            playIndicator.hidden = false
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
            
            setupPlayIndicator()
            setupSignal()
        }
    }
    
    func setupSignal() {
        signalImageView.hidden = true
        var animationImages = [UIImage]()
        for index in (1...4) {
            animationImages.append(UIImage(named: "ble\(index)")!)
        }
        
        signalImageView.animationImages = animationImages
        signalImageView.animationDuration = 0.9
        signalImageView.animationRepeatCount = 0
        startAnimating()
    }
    
    func setupPlayIndicator() {
        playIndicator.hidden = true
        playIndicator.layer.shadowColor = ColorPallete.Black.get().CGColor
        playIndicator.layer.shadowOpacity = 0.65
        playIndicator.layer.shadowRadius = 1.0
        playIndicator.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        playIndicator.clipsToBounds = false
        
        playingUpdateStatus()
    }
    
    func startAnimating() {
        signalImageView.startAnimating()
    }
    
    func playingUpdateStatus() {
        if !MediaPlayerService.shared.isPlayingArtwork(artwork) {
            status = .NotPlaying
        } else if MediaPlayerService.shared.paused {
            status = .Paused
        } else {
            status = .Playing
        }
    }
    
}
