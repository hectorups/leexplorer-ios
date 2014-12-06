//
//  NotificationManager.swift
//  leexplorer
//
//  Created by Hector Monserrate  on 12/4/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

class NotificationManager {
    private var observerTokens: [AnyObject] = []
    
    deinit {
        deregisterAll()
    }
    
    func deregisterAll() {
        for token in observerTokens {
            NSNotificationCenter.defaultCenter().removeObserver(token)
        }
        
        observerTokens = []
    }
    
    func registerObserverType(type: AppNotification, block: (NSNotification! -> Void)) {
        registerObserverType(type, forObject: nil, block: block)
    }
    
    func registerObserverType(type: AppNotification, forObject object: AnyObject?, block: (NSNotification! -> Void)) {
        registerObserverName(type.rawValue, forObject: object, block: block)
    }
    
    func registerObserverName(name: String, forObject object: AnyObject?, block: (NSNotification! -> Void)) {
        let newToken = NSNotificationCenter.defaultCenter().addObserverForName(name, object: object, queue: nil) {note in
            block(note)
        }
        
        observerTokens.append(newToken)
    }
}