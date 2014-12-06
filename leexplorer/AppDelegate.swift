//
//  AppDelegate.swift
//  leexplorer
//
//  Created by Hector Monserrate on 24/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import UIKit
import CoreData
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
        Fabric.with([Crashlytics()])
        Crashlytics.setValue(AppConstant.CLIENT_VERSION, forKey: "version")
        Crashlytics.setBoolValue(AppConstant.DEBUG, forKey: "debug")
        
        Mixpanel.sharedInstanceWithToken(AppConstant.MIXPANEL_TOKEN)
        
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
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Setups
    
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

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.leexplorer.ios.leexplorer" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("leexplorer", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("leexplorer.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
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

