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
    
    private let notificationManager = NotificationManager()
    
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
                var beacons = notification.userInfo!["beacons"] as [CLBeacon]
                LELog.d("Beacons found: \(beacons.count)")
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
            self.artworksCollectionView.reloadData()
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }) { (operation, error) -> Void in
            LELog.d(error)
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
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
