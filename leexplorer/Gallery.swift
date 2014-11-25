//
//  Gallery.swift
//  leexplorer
//
//  Created by Hector Monserrate on 24/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

class Gallery {

    var address: String!
    var desc: String!
    var name: String!
    var type: String!
    
    
    class func createFromJSON(data: NSDictionary) -> Gallery {
        var gallery = Gallery()
        
        gallery.address = data["address"] as String
        gallery.desc = data["description"] as String
        gallery.name = data["name"] as String
        gallery.type = data["type"] as String
        
        return gallery
    }

}
