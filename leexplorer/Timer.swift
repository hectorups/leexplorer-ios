//
//  TimerManager.swift
//  leexplorer
//
//  Created by Hector Monserrate  on 12/4/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

class Timer {
    var timer = NSTimer()
    var handler: () -> ()
    
    let interval: Double
    
    init(interval: Double, handler: () -> ()) {
        self.interval = interval
        self.handler = handler
    }
    
    func start() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(interval,
            target: self,
            selector: Selector("tick"),
            userInfo: nil,
            repeats: true)
    }
    
    func stop() {
        timer.invalidate()
    }
    
    @objc func tick() {
        self.handler()
    }
    
    deinit {
        self.timer.invalidate()
    }
}