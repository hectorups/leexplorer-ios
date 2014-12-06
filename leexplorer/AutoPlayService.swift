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
        stop()
        self.gallery = gallery
        self.artworks = artworks
        setupNotifications()
    }
    
    func isPlayingGallery(gallery: Gallery) -> Bool {
        if let currentGallery = self.gallery {
            return currentGallery == gallery
        } else {
            return false
        }
    }
    
    func stop() {
        notificationManager.deregisterAll()
        gallery = nil
        artworks = nil
        playedArtworks = []
    }
    
    // MARK: - Logic
    
    private func findNextArtworkToPlay(beacons: [CLBeacon]) {
        if beacons.count == 0 || artworks == nil || !MediaPlayerService.shared.isAvailable() {
            return
        }
        
        var presentArtworks: [Artwork] = artworks!.filter(){ find(self.playedArtworks, $0) == nil }
            .filter() {
                if let beacon = $0.findFromBeacons(beacons) {
                    return beacon.accuracy < AppConstant.MAX_BEACON_PROXIMITY
                } else {
                    return false
                }
        }
        
        Artwork.sortArtworks(&presentArtworks, beacons: beacons)
        
        if let nextArtwork = presentArtworks.first {
            playArtwork(nextArtwork)
        }
    }
    
    private func artworkStartedPlaying(artwork: Artwork) {
        if find(playedArtworks, artwork) != nil {
            return
        }
        
        for galleryArtwork in artworks! {
            if galleryArtwork == artwork {
                addToPlayedArtworks(artwork)
            }
        }
    }
    
    private func playArtwork(artwork: Artwork) {
        MediaPlayerService.shared.playArtwork(artwork)
        addToPlayedArtworks(artwork)
        
        let data = ["artworkId": artwork.id]
        NSNotificationCenter.defaultCenter().postNotificationName(AppNotification.AutoPlayTrackStarted.rawValue,
            object: self, userInfo: data)
    }
    
    private func addToPlayedArtworks(artwork: Artwork) {
        playedArtworks.append(artwork)
        
        if playedArtworks.count == artworks!.count {
            stop()
        }
    }
    
}