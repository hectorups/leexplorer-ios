//
//  ArtworkListViewController.swift
//  leexplorer
//
//  Created by Hector Monserrate on 26/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import UIKit
import CoreLocation

class ArtworkListViewController: UIViewController, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    
    @IBOutlet var artworksCollectionView: UICollectionView!
    @IBOutlet weak var autoPlayButton: MKButton!
    @IBOutlet weak var autoPlayIcon: UIImageView!
    
    let REFRESH_INTERVAL = 25.0 // seconds
    var gallery: Gallery!
    var artworks: [Artwork] = []
    var beacons: [CLBeacon] = []
    
    private let notificationManager = NotificationManager()
    private var waitingForBeacons: Bool = false
    
    override func viewDidLoad() {
        title = NSLocalizedString("ARTWORKS", comment: "")
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        setupAutoplay()
        setupBeaconUpdates()
        setupCollectionView()
        setupNotifications()
        loadArtworks()
    }
    
    deinit {
        LELog.d("ArtworkListViewController deinit")
        notificationManager.deregisterAll()
    }
    
    // MARK - SETUP
    
    func setupAutoplay() {
        autoPlayIcon.fixTemplateImage()
        autoPlayIcon.tintColor = ColorPallete.White.get()
        autoPlayButton.cornerRadius = 40.0
        autoPlayButton.backgroundLayerCornerRadius = 40.0
        autoPlayButton.maskEnabled = false
        autoPlayButton.rippleLocation = .Center
        autoPlayButton.rippleAniDuration = 0.85
        autoPlayButton.fixTemplateImage()
        autoPlayButton.tintColor = ColorPallete.Blue.get()
        
        autoPlayButton.layer.shadowOpacity = 0.65
        autoPlayButton.layer.shadowRadius = 2.5
        autoPlayButton.layer.shadowColor = UIColor.blackColor().CGColor
        autoPlayButton.layer.shadowOffset = CGSize(width: 1.0, height: 3.5)
        
        autoPlayButton.hidden = AutoPlayService.shared.isPlayingGallery(gallery)
        autoPlayIcon.hidden = autoPlayButton.hidden
    }
    
    func setupBeaconUpdates() {
        Timer(interval: REFRESH_INTERVAL) { [weak self] () -> () in
            if let strongSelf = self {
                strongSelf.waitingForBeacons = true
            }
        }.start()
    }
    
    func setupNotifications() {
        notificationManager.registerObserverType(.BeaconsFound) { [weak self] (notification) -> Void in
            if let strongSelf = self {
                strongSelf.beacons = notification.userInfo!["beacons"] as! [CLBeacon]
                
                if strongSelf.waitingForBeacons && strongSelf.beacons.count > 0 {
                    strongSelf.waitingForBeacons = false
                    strongSelf.sortAndShowArtworks()
                }
            }
        }
        
        notificationManager.registerObserverType(.AutoPlayEnded) { [weak self] (notification) -> Void in
            if let strongSelf = self {
                strongSelf.autoPlayButton.hidden = false
                strongSelf.autoPlayButton.alpha = 1.0
                strongSelf.autoPlayButton.userInteractionEnabled = true
                strongSelf.autoPlayIcon.hidden = false
                strongSelf.autoPlayIcon.alpha = 1.0
            }
        }
        
        let audioNotifications: [AppNotification] = [.AudioStarted, .AudioCompleted, .AudioPaused, .AudioResumed]
        notificationManager.registerObserverType(audioNotifications) { [weak self] (notification) -> Void in
            var artworkId = notification.userInfo!["artworkId"] as! String
            if let strongSelf = self {
                strongSelf.updateCellPlayingforArtwork()
            }
        }
    }
    
    func setupCollectionView() {
        var layout = artworksCollectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout
        layout.columnCount = 2
        layout.minimumColumnSpacing = 2
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsetsMake(1, 1, 1, 1)
        
        artworksCollectionView.backgroundColor = ColorPallete.AppBg.get()
        artworksCollectionView.delegate = self
        artworksCollectionView.dataSource = self
    }
    
    func loadArtworks() {
        if LeexplorerApi.shared.isInternetReachable() && !AppConstant.OFFLINE_MODE {
            loadArtworksFromAPI()
        } else {
            loadArtworksFromDB()
        }
    }
    
    func loadArtworksFromDB() {
        LELog.d("Load Artworks from DB")
        artworks = Artwork.allFromGallery(gallery)
        if self.beacons.count == 0 {
            self.waitingForBeacons = true
        }
        self.sortAndShowArtworks()
    }
    
    func loadArtworksFromAPI() {
        progressStartAnimatingWithTitle(NSLocalizedString("LOADING_ARTWORKS", comment: ""))
        LeexplorerApi.shared.getGalleryArtworks(gallery, success: { (artworks) -> Void in
            self.artworks = artworks
            if self.beacons.count == 0 {
                self.waitingForBeacons = true
            }
            self.sortAndShowArtworks()
            self.progressStopAnimating()
        }) { (operation, error) -> Void in
            LELog.d(error)
            self.loadArtworksFromDB()
            self.progressStopAnimating()
        }
    }
    
    // MARK - NewBeacons
    
    func sortAndShowArtworks() {
        Artwork.sortArtworks(&artworks, beacons: beacons)
        
        artworksCollectionView.performBatchUpdates({ () -> Void in
            self.artworksCollectionView.reloadSections(NSIndexSet(index: 0))
        }, completion: nil)
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ArtworkCollectionViewCell", forIndexPath: indexPath) as! ArtworkCollectionViewCell
        
        let artwork = artworks[indexPath.row]
        cell.artwork = artwork
        cell.accuracy = artwork.findFromBeacons(beacons)?.accuracy
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ArtworkCollectionViewCell
        cell.startAnimating()
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ArtworkCollectionViewCell
        cell.startAnimating()
    }
    
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ArtworkCollectionViewCell
        cell.startAnimating()
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Segue.ShowArtworkProfile.rawValue {
            var controller = segue.destinationViewController as! ArtworkProfileViewController
            let cell = sender as! ArtworkCollectionViewCell
            controller.artwork = cell.artwork
            controller.gallery = gallery
        }
    }
    
    // MARK: - Autoplay 
    
    @IBAction func didTabAutoplay(sender: AnyObject) {
        AutoPlayService.shared.playGallery(gallery, artworks: artworks)
        
        autoPlayButton.userInteractionEnabled = false
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.autoPlayButton.alpha = 0.0
            self.autoPlayIcon.alpha = 0.0
            }) { (_) -> Void in
                self.autoPlayButton.hidden = true
                self.autoPlayIcon.hidden = self.autoPlayButton.hidden
        }
    }
    
    // MARK: - Update Cell playing 
    
    func updateCellPlayingforArtwork() {
        for cell in artworksCollectionView.visibleCells() {
            let artworkCell = cell as! ArtworkCollectionViewCell
            artworkCell.playingUpdateStatus()
        }
    }
    
    
}
