//
//  Image.swift
//  leexplorer
//
//  Created by Hector Monserrate on 25/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation
import Realm

class Image: RLMObject {
    dynamic var publicId: String = ""
    dynamic var height: Int = 0
    dynamic var width: Int = 0
    dynamic var format: String = ""
    dynamic var bytes: Int = 0
    
    override class func primaryKey() -> String {
        return "publicId"
    }
    
    class func createFromJSON(data: NSDictionary) -> Image {
        var image = Image()
        image.publicId = data["public_id"] as String
        image.height = data["height"] as Int
        image.width = data["width"] as Int
        image.format = data["format"] as String
        image.bytes = data["bytes"] as Int
        
        return image
    }
}