//
//  EventReporter.swift
//  leexplorer
//
//  Created by Hector Monserrate on 02/12/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

enum EventReporterType: String {
    case ArtworkAudioPlayed = "arwork_audio_played",
    GalleryDiscovered = "gallery_discovered",
    GalleryDownloaded = "gallery_downloaded"
}

enum EventAttribute: String {
    case ArtworkMac = "artwork_mac",
    ArtworkName = "artwork_name",
    ArtworkId = "artwork_id",
    GalleryName = "gallery_name",
    GalleryId = "gallery_id"
}

class EventReporter {
    
    class var shared: EventReporter {
        struct Static {
            static let instance : EventReporter = EventReporter()
        }
        return Static.instance
    }
    
    
    func artworkAudioPlayed(artwork: Artwork, gallery: Gallery) {
        let attributes = NSMutableDictionary()
        attributes.setValue(artwork.id, forKey: EventAttribute.ArtworkId.rawValue)
        attributes.setValue(artwork.name, forKey: EventAttribute.ArtworkName.rawValue)
        attributes.setValue(gallery.id, forKey: EventAttribute.GalleryId.rawValue)
        attributes.setValue(gallery.name, forKey: EventAttribute.GalleryName.rawValue)
        
        logEvent(.ArtworkAudioPlayed, attributes: attributes)
    }
    
    
    func logEvent(type: EventReporterType, attributes: [NSObject: AnyObject]) {
        
        if attributes.count > 0 {
            Mixpanel.sharedInstance().track(type.rawValue, properties: attributes)
        } else {
            Mixpanel.sharedInstance().track(type.rawValue)
        }
    }
}