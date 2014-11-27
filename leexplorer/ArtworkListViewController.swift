//
//  ArtworkListViewController.swift
//  leexplorer
//
//  Created by Hector Monserrate on 26/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import UIkit

class ArtworkListViewController: UIViewController, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    
    @IBOutlet var artworksCollectionView: UICollectionView!
    var gallery: Gallery!
    var artworks: [Artwork] = []
    
    override func viewDidLoad() {
        self.title = NSLocalizedString("ARTWORKS", comment: "")
        
        setupCollectionView()
        
        loadArtworks()
    }
    
    // MARK - SETUP
    
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
        LeexplorerApi.shared.getGalleryArtworks(gallery, success: { (artworks) -> Void in
            self.artworks = artworks
            self.artworksCollectionView.reloadData()
        }) { (operation, error) -> Void in
            LELog.d(error)
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
        }
    }
    
}
