//
//  AppDelegate.swift
//  leexplorer
//
//  Created by Hector Monserrate on 24/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var notificationManager = NotificationManager()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        LELog.d("APP VERSION: \(AppConstant.CLIENT_VERSION)")
        setup3rdPartyPlugins()
        setupReachability()
        setupNotifications()
        setupImageCache()
        initVisualAppearance()
        
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        if BLEService.shared.centralManager.state == .PoweredOn {
            BLEService.shared.monitorRegion()
        }
    }
    
    // MARK: - Setups
    
    func setup3rdPartyPlugins() {
        Fabric.with([Crashlytics()])
        Crashlytics.setValue(AppConstant.CLIENT_VERSION, forKey: "version")
        Crashlytics.setBoolValue(AppConstant.DEBUG, forKey: "debug")
        Mixpanel.sharedInstanceWithToken(AppConstant.MIXPANEL_TOKEN)
    }
    
    func setupReachability() {
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (status) -> Void in
            switch status {
            case .ReachableViaWiFi, .ReachableViaWWAN:
                LELog.d("Internet Reachable")
            default:
                LELog.d("Internet Unreachable")
            }
        }
    }
    
    func setupNotifications() {
        notificationManager.registerObserverType(.AutoPlayTrackStarted) { [weak self] (notification) in
            LELog.d("appdelegate: autoplay started")
            if let strongSelf = self {
                strongSelf.notifyNewAudio()
            }
        }
    }
    
    func setupImageCache() {
        let sharedCache = NSURLCache(memoryCapacity: 2 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
        NSURLCache.setSharedURLCache(sharedCache)
    }
    
    func initVisualAppearance() {
        let navigationBar = UINavigationBar.appearance()
        if SDKVersion.greaterOrEqualTo("8.0") {
            navigationBar.translucent = true
        }
        
        
        navigationBar.barStyle = .Default
        navigationBar.tintColor = ColorPallete.Blue.get()
        navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: ColorPallete.Blue.get()
        ]
    }

    
    // MARK: - Audio Controls
    override func remoteControlReceivedWithEvent(event: UIEvent) {
        let type = event.subtype
        LELog.d("received remote control \(type.rawValue)") // 101 = pause, 100 = play
        
        if !MediaPlayerService.shared.hasArtworkTrack() {
            // Ignore, not our track
            return
        }
        
        switch type {
        case .RemoteControlTogglePlayPause:
            if MediaPlayerService.shared.paused {
                MediaPlayerService.shared.play()
            } else {
                MediaPlayerService.shared.pause()
            }
        case .RemoteControlPlay:
            MediaPlayerService.shared.play()
        case .RemoteControlPause:
            MediaPlayerService.shared.pause()
        default:break
        }
        
    }
    
    // MARK: - AutoPlay notifications
    
    func notifyNewAudio() {
        if let window = self.window {
            let viewController = (window.rootViewController as UINavigationController).visibleViewController
            notifyWighAlert(viewController)
        }
    }
    
    func notifyWighAlert(viewController: UIViewController) {
        LELog.d("appdelegate: show alert")
        
        let alert = SCLAlertView()
        alert.backgroundType = .Blur
        alert.shouldDismissOnTapOutside = true
        alert.addButton(NSLocalizedString("AUTOPLAY_CANCEL", comment: ""), actionBlock: { () -> Void in
            AutoPlayService.shared.stop()
            MediaPlayerService.shared.stop()
        })
        
        var image = UIImage(named: "autoplay_icon")!.withColorTint(ColorPallete.White.get())
        
        alert.showCustom(viewController,
            image: image,
            color: ColorPallete.Blue.get(),
            title: NSLocalizedString("AUTOPLAY_TITLE", comment: ""),
            subTitle: NSLocalizedString("AUTOPLAY_SUBTITLE", comment: ""),
            closeButtonTitle: NSLocalizedString("AUTOPLAY_OK", comment: ""),
            duration: 10.0)
    }

}

