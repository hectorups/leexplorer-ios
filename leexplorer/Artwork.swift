//
//  Artwork.swift
//  leexplorer
//
//  Created by Hector Monserrate on 26/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation
import CoreLocation

class Artwork {
    var audio: Audio?
    var author: String?
    var desc: String?
    var image: Image!
    var likesCount: Int!
    var name: String!
    var publishedAt: NSDate?
    var galleryId: String!
    var major: Int?
    var minor: Int?
    var id: String!
    
    
    class func createFromJSON(data: NSDictionary) -> Artwork {
        var artwork =  Artwork()
        
        artwork.id = data["id"] as String
        if let audioData = data["audio"] as? NSDictionary {
            artwork.audio = Audio.createFromJSON(audioData)
        }
        artwork.author = data["author"] as? String
        artwork.desc = data["description"] as? String
        artwork.image = Image.createFromJSON(data["image"] as NSDictionary)
        artwork.likesCount = data["likes_count"] as Int
        artwork.name = data["name"] as String
        
        if let publishedAtString = data["published_at"] as? String {
            if let publishedAt = NSDate.leDateFromString(publishedAtString) {
                artwork.publishedAt = publishedAt
            }
        }
        
        artwork.galleryId = data["gallery_id"] as String
        artwork.major = data["major"] as? Int
        artwork.minor = data["minor"] as? Int
        
        return artwork
    }
    
    func belongsToBeacon(beacon: CLBeacon) -> Bool {
        return beacon.major == major && beacon.minor == minor
    }

    
}


func == <R: Artwork>(left: R, right: R) -> Bool {
    return left.id == right.id
}

