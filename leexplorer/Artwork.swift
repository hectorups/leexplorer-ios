//
//  Artwork.swift
//  leexplorer
//
//  Created by Hector Monserrate on 26/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation
import CoreLocation
import Realm

class Artwork: RLMObject, Equatable {
    dynamic var id = ""
    dynamic var audio: Audio?
    dynamic var image: Image!
    dynamic var author = ""
    dynamic var desc = ""
    dynamic var likesCount = 0
    dynamic var name = ""
    dynamic var publishedAtString = ""
    dynamic var galleryId = ""
    dynamic var major = 0
    dynamic var minor = 0
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    class func createFromJSON(data: NSDictionary) -> Artwork {
        var artwork = Artwork()
        
        artwork.id = data["id"] as String
        if let audioData = data["audio"] as? NSDictionary {
            artwork.audio = Audio.createFromJSON(audioData)
        }
        artwork.author = data["author"] as? String ?? ""
        artwork.desc = data["description"] as? String ?? ""
        artwork.image = Image.createFromJSON(data["image"] as NSDictionary)
        artwork.likesCount = data["likes_count"] as Int
        artwork.name = data["name"] as String
        
        artwork.publishedAtString = data["published_at"] as? String ?? ""
        
        artwork.galleryId = data["gallery_id"] as String
        artwork.major = data["major"] as? Int ?? 0
        artwork.minor = data["minor"] as? Int ?? 0
        
        return artwork
    }
    
    func hasMajorMinor() -> Bool {
        return major > 0 || minor > 0
    }
    
    func belongsToBeacon(beacon: CLBeacon) -> Bool {
        if !hasMajorMinor() {
            return false
        }
        
        return beacon.major == major && beacon.minor == minor
    }
    
    class func sortArtworks(inout artworks: [Artwork], beacons: [CLBeacon]) {
        artworks.sort { (artwork1, artwork2) -> Bool in
            let accuracy1 = artwork1.findFromBeacons(beacons)?.leNormalizedAccuracy() ?? DBL_MAX
            let accuracy2 = artwork2.findFromBeacons(beacons)?.leNormalizedAccuracy() ?? DBL_MAX
            
            return accuracy2 > accuracy1
        }
    }
    
    func findFromBeacons(beacons: [CLBeacon]) -> CLBeacon? {
        for beacon in beacons {
            if belongsToBeacon(beacon) {
                return beacon
            }
        }
        
        return nil
    }

    func publishedAt() -> NSDate? {
        if let publishedAt = NSDate.leDateFromString(publishedAtString) {
            return publishedAt
        }
        
        return nil
    }
    
    class func allFromGallery(gallery: Gallery) -> [Artwork] {
        var artworks = [Artwork]()
        for object in Artwork.objectsWhere("galleryId = '\(gallery.id)'") {
            artworks.append(object as Artwork)
        }
        
        return artworks
    }
    
    class func findById(id: String) -> Artwork? {
        return Artwork.objectsWhere("id = '\(id)'").firstObject() as Artwork?
    }
}


func == (left: Artwork, right: Artwork) -> Bool {
    return left.id == right.id
}

