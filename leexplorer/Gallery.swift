//
//  Gallery.swift
//  leexplorer
//
//  Created by Hector Monserrate on 24/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

class Gallery: Equatable {
    
    var id: String!
    var address: String!
    var desc: String!
    var name: String!
    var type: String!
    var latitude: Double!
    var longitude: Double!
    var languages: [String]!
    var hours: String!
    var priceDescription: String!
    var priceReference: Int!
    var updatedAt: NSDate!
    var images: [Image]!

    
    class func createFromJSON(data: NSDictionary) -> Gallery {
        var gallery = Gallery()
        
        gallery.id = data["id"] as String
        gallery.address = data["address"] as String
        gallery.desc = data["description"] as String
        gallery.name = data["name"] as String
        gallery.type = data["type"] as String
        gallery.latitude = data["latitude"] as Double
        gallery.longitude = data["longitude"] as Double
        
        gallery.languages = []
        for language in data["languages"] as [String] {
            gallery.languages.append(language)
        }
        
        gallery.hours = data["hours"] as String
        gallery.priceDescription = data["price_description"] as String
        gallery.priceReference = data["price_reference"] as Int
        gallery.updatedAt = NSDate.leDateFromString(data["updatedAt"] as String)!
        
        let imagesData = data["images"] as [NSDictionary]
        gallery.images = []
        for imageData in imagesData as [NSDictionary] {
            let image = Image.createFromJSON(imageData)
            gallery.images.append(image)
        }
        
        return gallery
    }

}

func == (left: Gallery, right: Gallery) -> Bool {
    return left.id == right.id
}
