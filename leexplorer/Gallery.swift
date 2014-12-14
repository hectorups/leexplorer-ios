//
//  Gallery.swift
//  leexplorer
//
//  Created by Hector Monserrate on 24/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation
import Realm

class Gallery: RLMObject, Equatable {
    
    dynamic var id = ""
    dynamic var address = ""
    dynamic var desc = ""
    dynamic var name = ""
    dynamic var type = ""
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    dynamic var languagesString = ""
    dynamic var images = RLMArray(objectClassName: Image.className())
    dynamic var hours = ""
    dynamic var priceDescription = ""
    dynamic var priceReference = 0
    
    var updatedAt = NSDate()
    
    func ignoredProperties() -> NSArray {
        return [updatedAt]
    }

    override class func primaryKey() -> String {
        return "id"
    }
    
    class func createFromJSON(data: NSDictionary) -> Gallery {
        var gallery = Gallery()
        
        gallery.id =  data["id"] as String
        gallery.address = data["address"] as String
        gallery.desc = data["description"] as String
        gallery.name = data["name"] as String
        gallery.type = data["type"] as String
        gallery.latitude = data["latitude"] as Double
        gallery.longitude = data["longitude"] as Double
        
        gallery.setLanguages(data["languages"] as [String] )
        
        gallery.hours = data["hours"] as String
        gallery.priceDescription = data["price_description"] as String
        gallery.priceReference = data["price_reference"] as Int
        gallery.updatedAt = NSDate.leDateFromString(data["updatedAt"] as String)!
        
        let imagesData = data["images"] as [NSDictionary]
        for imageData in imagesData as [NSDictionary] {
            let image = Image.createFromJSON(imageData)
            gallery.images.addObject(image)
        }
        
        return gallery
    }
    
    func setLanguages(value: [String]) {
        languagesString = ",".join(value)
    }
    
    func getLanguages() -> [String] {
        return languagesString.componentsSeparatedByString(",")
    }
    
    class func allGalleries() -> [Gallery] {
        return PersistantManager.shared.getAll()
    }
    
    func downloadedAt() -> NSDate? {
        return NSUserDefaults.standardUserDefaults().objectForKey(downloadedAtKey()) as NSDate?
    }
    
    func setDownloadedAt(date: NSDate) {
        NSUserDefaults.standardUserDefaults().setObject(date, forKey: downloadedAtKey())
    }
    
    private func downloadedAtKey() -> String {
        return "gallery_\(id)_downloadedAt"
    }
    
    class func findById(id: String) -> Gallery? {
        return Artwork.objectsWhere("id = '\(id)'").firstObject() as Gallery?
    }

}

func == (left: Gallery, right: Gallery) -> Bool {
    return left.id == right.id
}
