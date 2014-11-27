//
//  ArtworkListViewController.swift
//  leexplorer
//
//  Created by Hector Monserrate on 26/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import UIkit

class ArtworkListViewController: UIViewController, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    
    var gallery: Gallery!
    
    override func viewDidLoad() {
        
        loadArtworks()
    }
    
    func loadArtworks() {
        LeexplorerApi.shared.getGalleryArtworks(gallery, success: { (artworks) -> Void in
            
        }) { (operation, error) -> Void in
            LELog.d(error)
        }
    }
}
