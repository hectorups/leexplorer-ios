//
//  LocationService.swift
//  leexplorer
//
//  Created by Hector Monserrate  on 12/9/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    let REQUEST_INTERVAL: Double = 60 * 5
    
    var location: CLLocation?
    private var locationManager: CLLocationManager
    private var requested: Bool = false
    
    class var shared : LocationService {
        struct Static {
            static let instance = LocationService()
        }
        return Static.instance
    }
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        if locationManager.respondsToSelector("requestWhenInUseAuthorization") ?? false {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationPresent() -> Bool {
        return location != nil
    }
    
    func requestLocation() {
        if self.requested {
            return
        }
        locationManager.startUpdatingLocation()
        requested = true
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        LELog.e("error = \(error)")
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as CLLocation
        if location.horizontalAccuracy > 0 {
            self.location = location
            locationManager.stopUpdatingLocation()
        }
        requested = false
        
        sendNotification()
    }
    
    private func sendNotification() {
        let data = ["location": location!]
        NSNotificationCenter.defaultCenter().postNotificationName(AppNotification.LocationUpdate.rawValue,
            object: self, userInfo: data)
    }
    
    private func prepareNextRequest() {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(REQUEST_INTERVAL * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), {
            self.locationManager.startUpdatingLocation()
        })
    }
}