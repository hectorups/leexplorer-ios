//
//  Image.swift
//  leexplorer
//
//  Created by Hector Monserrate on 25/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

class Image {
    var publicId: String!
    var height: Int!
    var width: Int!
    var format: String!
    var bytes: Int!
    
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