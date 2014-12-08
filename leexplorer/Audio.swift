//
//  Audio.swift
//  leexplorer
//
//  Created by Hector Monserrate on 26/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation
import Realm

class Audio: RLMObject {
    dynamic var locale: String = ""
    dynamic var publicId: String = ""
    dynamic var bytes: Int = 0
    
    override class func primaryKey() -> String {
        return "publicId"
    }
    
    class func createFromJSON(data: NSDictionary) -> Audio {
        var audio = Audio()
        audio.locale = data["locale"] as String
        audio.publicId = data["public_id"] as String
        audio.bytes = data["bytes"] as Int
        
        return audio
    }
    
    
}