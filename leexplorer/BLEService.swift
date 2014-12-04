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
        
        if locationManager.respondsToSelector("requestAlwaysAuthorization") ?? false {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func monitorRegion() {
        println("Start monitoring ---")
        
        Region.notifyEntryStateOnDisplay = true
        Region.notifyOnEntry = true
        Region.notifyOnExit = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startMonitoringForRegion(Region)
        locationManager.requestStateForRegion(Region)
        locationManager.startUpdatingLocation()
    }
    
    
    // MARK: CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        println("ble status changed: \(central.state.rawValue)")
        if central.state == .PoweredOn {
            monitorRegion()
        }
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        let foundBeacons = (beacons as [CLBeacon])
        let data = ["beacons": foundBeacons]
        NSNotificationCenter.defaultCenter().postNotificationName(AppNotification.BeaconsFound.rawValue, object: self, userInfo: data)
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        // Updated state
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

}