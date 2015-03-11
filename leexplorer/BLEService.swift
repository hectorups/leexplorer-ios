//
//  BLEService.swift
//  leexplorer
//
//  Created by Hector Monserrate  on 12/4/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth

class BLEService: NSObject, CBCentralManagerDelegate, CLLocationManagerDelegate {
    let Region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: AppConstant.LE_UUID), identifier: "leexplorer")
    
    var centralManager: CBCentralManager!
    var locationManager: CLLocationManager!
    
    class var shared : BLEService {
        struct Static {
            static let instance = BLEService()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        if locationManager.respondsToSelector("requestWhenInUseAuthorization") ?? false {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func monitorRegion() {
        LELog.d("Start monitoring ---")
        
        
        if locationManager.respondsToSelector("requestWhenInUseAuthorization") ?? false {
            locationManager.startRangingBeaconsInRegion(Region)
            return
        }
        
        Region.notifyEntryStateOnDisplay = true
        Region.notifyOnEntry = true
        Region.notifyOnExit = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startMonitoringForRegion(Region)
        locationManager.requestStateForRegion(Region)
    }
    
    func isAuthorized() -> Bool {
        let currentStatus = CLLocationManager.authorizationStatus()
        return currentStatus == CLAuthorizationStatus.AuthorizedWhenInUse || currentStatus == CLAuthorizationStatus.AuthorizedAlways
    }
    
    
    // MARK: CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        LELog.d("ble status changed: \(central.state.rawValue)")
        if central.state == .PoweredOn && isAuthorized() {
            monitorRegion()
        }
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        
//        LELog.d("Beacons found: \(beacons.count)")
        let foundBeacons = (beacons as [CLBeacon])
        let data = ["beacons": foundBeacons]
        NSNotificationCenter.defaultCenter().postNotificationName(AppNotification.BeaconsFound.rawValue, object: self, userInfo: data)
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        // Updated state
        LELog.d("Region state: \(state.rawValue)")
        if state == .Inside {
            locationManager.startRangingBeaconsInRegion(region as CLBeaconRegion)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        LELog.d("enter region \(region.identifier)")
        locationManager.startRangingBeaconsInRegion(region as CLBeaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        LELog.d("exit region \(region.identifier)")
        locationManager.stopRangingBeaconsInRegion(region as CLBeaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        LELog.e("Location manager failed: \(error)")
    }
    
    func locationManager(manager: CLLocationManager!, rangingBeaconsDidFailForRegion region: CLBeaconRegion!, withError error: NSError!) {
        LELog.e("Location manager failed: \(error)")
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        LELog.d("Authorization for ble updated")
        if isAuthorized() {
            monitorRegion()
        }
    }

}