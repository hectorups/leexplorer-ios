//
//  ArtworkListViewController.swift
//  leexplorer
//
//  Created by Hector Monserrate on 26/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import UIkit
import CoreLocation

class ArtworkListViewController: UIViewController, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    
    @IBOutlet var artworksCollectionView: UICollectionView!
    var gallery: Gallery!
    var artworks: [Artwork] = []
    var beacons: [CLBeacon] = []
    
    private let notificationManager = NotificationManager()
    private var waitingForBeacons = false
    
    override func viewDidLoad() {
        title = NSLocalizedString("ARTWORKS", comment: "")
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        setupCollectionView()
        setupNotifications()
        loadArtworks()
    }
    
    deinit {
        LELog.d("ArtworkListViewController deinit")
        notificationManager.deregisterAll()
    }
    
    // MARK - SETUP
    
    func setupNotifications() {
        notificationManager.registerObserver(.BeaconsFound) { [weak self] (notification) -> Void in
            if let strongSelf = self {
                strongSelf.beacons = notification.userInfo!["beacons"] as [CLBeacon]
                
                if strongSelf.waitingForBeacons {
                    strongSelf.waitingForBeacons = false
                    strongSelf.sortAndShowArtworks()
                }
            }
        }
    }
    
    func setupCollectionView() {
        var layout = artworksCollectionView.collectionViewLayout as CHTCollectionViewWaterfallLayout
        layout.columnCount = 2
        layout.minimumColumnSpacing = 2
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsetsMake(1, 1, 1, 1)
        
        artworksCollectionView.delegate = self
        artworksCollectionView.dataSource = self
    }
    
    func loadArtworks() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        LeexplorerApi.shared.getGalleryArtworks(gallery, success: { (artworks) -> Void in
            self.artworks = artworks
            if self.beacons.count == 0 {
                self.waitingForBeacons = true
            }
            self.sortAndShowArtworks()
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }) { (operation, error) -> Void in
            LELog.d(error)
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
    }
    
    // MARK - NewBeacons
    
    func sortAndShowArtworks() {
        sortArtworks()
        artworksCollectionView.reloadData()
    }
    
    func sortArtworks() {
        artworks.sort { (artwork1, artwork2) -> Bool in
            let accuracy1 = self.accuracyForArtwork(artwork1) ?? DBL_MAX
            let accuracy2 = self.accuracyForArtwork(artwork2) ?? DBL_MAX
            
            return accuracy2 > accuracy1
        }
    }
    
    func accuracyForArtwork(artwork: Artwork) ->  CLLocationAccuracy? {
        for beacon in beacons {
            if artwork.belongsToBeacon(beacon) {
                return beacon.accuracy
            }
        }
        
        return nil
    }
    
    // MARK - CHTCollectionViewDelegateWaterfallLayout
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artworks.count
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        var height: Int!
        switch artworks[indexPath.row].likesCount {
        case 0...51:
            height = 50
        case 51...100:
            height = 60
        default:
            height = 80
        }
        
        return CGSize(width: 50, height: height)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ArtworkCollectionViewCell", forIndexPath: indexPath) as ArtworkCollectionViewCell
        
        cell.artwork = artworks[indexPath.row]
        cell.hasBeacon = false
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Segue.ShowArtworkProfile.rawValue {
            var controller = segue.destinationViewController as ArtworkProfileViewController
            let cell = sender as ArtworkCollectionViewCell
            controller.artwork = cell.artwork
            controller.gallery = gallery
        }
    }
    
}
