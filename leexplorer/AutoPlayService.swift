//
//  AutoPlayService.swift
//  leexplorer
//
//  Created by Hector Monserrate  on 12/5/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation
import CoreLocation

class AutoPlayService: NSObject {
    private var gallery: Gallery?
    private var artworks: [Artwork]?
    private var playedArtworks: [Artwork] = []
    private var notificationManager: NotificationManager
    
    class var shared : AutoPlayService {
        struct Static {
            static let instance = AutoPlayService()
        }
        return Static.instance
    }
    
    override init() {
        notificationManager = NotificationManager()
        super.init()
        setupNotifications()
    }
    
    // MARK: - Setup
    
    func setupNotifications() {
        notificationManager.registerObserverType(.BeaconsFound) { [weak self] (notification) -> Void in
            if let strongSelf = self {
                var beacons = notification.userInfo!["beacons"] as [CLBeacon]
                strongSelf.findNextArtworkToPlay(beacons)
            }
        }
        
        notificationManager.registerObserverType(.AudioStarted) { [weak self] (notification) -> Void in
            var artworkId = notification.userInfo!["artworkId"] as String
            if let strongSelf = self {
                if let artworks = strongSelf.artworks {
                    var artwork = artworks.filter({ (artwork) -> Bool in
                        for artwork in artworks {
                            if artwork.id == artworkId {
                                return true
                            }
                        }
                        return false
                    }).first
                    
                    if artwork != nil {
                        strongSelf.artworkStartedPlaying(artwork!)
                    }
                }
            }
        }
    }
    
    // MARK: - Controls
    
    func playGallery(gallery: Gallery, artworks: [Artwork]) {
        self.gallery = gallery
        self.artworks = artworks
        self.playedArtworks = []
    }
    
    // MARK: - Logic
    
    private func findNextArtworkToPlay(beacons: [CLBeacon]) {
        if beacons.count == 0 || artworks == nil || !MediaPlayerService.shared.isAvailable() {
            return
        }
        
        var presentArtworks: [Artwork] = artworks!.filter(){ find(self.playedArtworks, $0) == nil }.filter(){ $0.findFromBeacons(beacons) != nil }
        
        Artwork.sortArtworks(&presentArtworks, beacons: beacons)
        
        if let nextArtwork = presentArtworks.first {
            MediaPlayerService.shared.playArtwork(nextArtwork)
            playedArtworks.append(nextArtwork)
        }
    }
    
    private func artworkStartedPlaying(artwork: Artwork) {
        if find(playedArtworks, artwork) != nil {
            return
        }
        
        for galleryArtwork in artworks! {
            if galleryArtwork == artwork {
                playedArtworks.append(artwork)
            }
        }
    }
    
}