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
    
    func persistInBackgroundWithBlock<T: RLMObject>(collecitonBlock: () -> [T]) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) { () -> Void in
            let collection = collecitonBlock()
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