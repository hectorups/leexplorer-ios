//
//  PersistantManager.swift
//  leexplorer
//
//  Created by Hector Monserrate  on 12/7/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation
import Realm

class PersistantManager {
    
    class var shared: PersistantManager {
        struct Static {
            static let instance = PersistantManager()
        }
        return Static.instance
    }
    
    func persistCollection<T: RLMObject>(collection: [T]) {
        let realm = RLMRealm.defaultRealm()
        realm.beginWriteTransaction()
        for item in collection {
            realm.addOrUpdateObject(item)
        }
        realm.commitWriteTransaction()
    }
    
    func persistCollectionInBackground<T: RLMObject>(collection: [T]) {
        dispatch_async(dispatch_queue_create("background", 0)) {
            self.persistCollection(collection)
        }
    }
    
    func getAll<T: RLMObject>() -> [T] {
        let results = T.allObjects()
        var collection = [T]()
        for result in results {
            collection.append(result as T)
        }
        
        return collection
    }
    
}