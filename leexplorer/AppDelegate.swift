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
class AppDelegate: UIResponder, UIApplicationDelegate, COSTouchVisualizerWindowDelegate {

    var notificationManager = NotificationManager()
    lazy var window: UIWindow? = {
        COSTouchVisualizerWindow(frame: UIScreen.mainScreen().bounds)
    }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        LELog.d("APP VERSION: \(AppConstant.CLIENT_VERSION)")
        
        setup3rdPartyPlugins() // This has to be first
        setupCosTouch()
        setupLocationService()
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
    func setupCosTouch() {
        if let cosWindow = window as? COSTouchVisualizerWindow {
            cosWindow.strokeColor = UIColor(hexString: "#e9e9e9")
            cosWindow.fillColor = UIColor(hexString: "#333333")
            cosWindow.rippleStrokeColor = UIColor(hexString: "#e9e9e9")
            cosWindow.rippleFillColor = UIColor(hexString: "#333333")
            cosWindow.touchVisualizerWindowDelegate = self
        }
    }
    
    func setupLocationService() {
        LocationService.shared.requestLocation()
    }
    
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
                let artworkId = notification.userInfo!["artworkId"] as! String
                let artwork = Artwork.findById(artworkId)!
                strongSelf.notifyNewAudio(artwork)
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
    
    func notifyNewAudio(artwork: Artwork) {
        if let window = self.window {
            let viewController = window.rootViewController as! UINavigationController
            notifyWighAlert(viewController, artwork: artwork)
        }
    }
    
    func notifyWighAlert(viewController: UIViewController, artwork: Artwork) {
        LELog.d("appdelegate: show alert")
        
        let alert = SCLAlertView()
        alert.backgroundType = .Blur
        alert.shouldDismissOnTapOutside = false

        alert.addButton(NSLocalizedString("AUTOPLAY_OK", comment: ""), actionBlock: { () -> Void in
            AutoPlayService.shared.confirm()
        })
        
        alert.addButton(NSLocalizedString("AUTOPLAY_SKIP", comment: ""), actionBlock: { () -> Void in
            AutoPlayService.shared.skip()
        })
        
        alert.addButton(NSLocalizedString("AUTOPLAY_CANCEL", comment: ""), actionBlock: { () -> Void in
            AutoPlayService.shared.stop()
        })
        
        var image = UIImage(named: "autoplay_icon")!.withColorTint(ColorPallete.White.get())
        
        alert.showCustom(viewController,
            image: image,
            color: ColorPallete.Blue.get(),
            title: NSLocalizedString("AUTOPLAY_TITLE", comment: ""),
            subTitle: NSString(format: NSLocalizedString("AUTOPLAY_SUBTITLE", comment: ""), artwork.name) as String,
            closeButtonTitle: nil,
            duration: 0.0)
    }
    
    // MARK: - Background Downloads
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        TWRDownloadManager.sharedManager().backgroundTransferCompletionHandler = completionHandler
    }
    
    // MARK: COSTouchVisualizerWindowDelegate
    
    func touchVisualizerWindowShouldAlwaysShowFingertip(window: COSTouchVisualizerWindow!) -> Bool {
        return true
    }
    
    func touchVisualizerWindowShouldShowFingertip(window: COSTouchVisualizerWindow!) -> Bool {
        return DEBUG == 1
    }

}

