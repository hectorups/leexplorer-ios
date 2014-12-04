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
    
    func registerObserver(name: AppNotification, block: (NSNotification! -> Void)) {
        registerObserver(name, forObject: nil, block: block)
    }
    
    func registerObserver(name: AppNotification, forObject object: AnyObject?, block: (NSNotification! -> Void)) {
        let newToken = NSNotificationCenter.defaultCenter().addObserverForName(name.rawValue, object: object, queue: nil) {note in
            block(note)
        }
        
        observerTokens.append(newToken)
    }
}