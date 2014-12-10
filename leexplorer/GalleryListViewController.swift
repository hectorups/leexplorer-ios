//
//  ViewController.swift
//  leexplorer
//
//  Created by Hector Monserrate on 24/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import UIKit
import CoreLocation

class GalleryListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GalleryCellDelegate {

    @IBOutlet var tableView: UITableView!
    
    let GALLERY_CELL_HEIGHT: CGFloat = 240
    
    var galleries: [Gallery] = []
    var notificationManager = NotificationManager()
    var waitingForLocation = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("GALLERY_LIST_TITLE", comment: "")
        
        setupNotifications()
        setupTableView()
        
        if LocationService.shared.locationPresent() {
            loadGalleries()
        }
    }
    
    // MARK: - Setup
    
    func setupTableView() {
        tableView.backgroundColor = ColorPallete.AppBg.get()
        tableView.delegate = self
        tableView.dataSource = self
        
        let cellNib = UINib(nibName: "GalleryCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "GalleryCell")
    }
    
    func setupNotifications() {
        notificationManager.registerObserverType(.LocationUpdate) { [weak self] (notification) -> Void in
            if let strongSelf = self {
                if strongSelf.waitingForLocation {
                    strongSelf.loadGalleries()
                }
                strongSelf.waitingForLocation = false
            }
        }
    }
    
    // MARK: - TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.galleries.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("GalleryCell") as GalleryCell
        cell.height = GALLERY_CELL_HEIGHT
        cell.gallery = self.galleries[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return GALLERY_CELL_HEIGHT
    }
    
    // MARK: - Load Galleries
    
    func loadGalleries() {
        if LeexplorerApi.shared.isInternetReachable() && !AppConstant.OFFLINE_MODE {
            loadGalleriesFromAPI()
        } else {
            loadGalleriesFromDB()
        }
    }
    
    func loadGalleriesFromDB() {
        LELog.d("Load galleries from DB")
        let galleries = Gallery.allGalleries().filter(){ $0.downloadedAt() != nil }
        sortAndShowGalleries(galleries)
    }
    
    func loadGalleriesFromAPI() {
        progressStartAnimatingWithTitle(NSLocalizedString("LOADING_GALLERIES", comment: ""))
        LeexplorerApi.shared.getGalleries({ (galleries) -> Void in
            LELog.d(galleries.count)
            self.sortAndShowGalleries(galleries)
            self.progressStopAnimating()
        }, failure: { (operation, error) -> Void in
            LELog.e(error)
            self.loadGalleriesFromDB()
            self.progressStopAnimating()
        })
        
    }
    
    func sortAndShowGalleries(galleries: [Gallery]) {
        let currentLocation = LocationService.shared.location!
        self.galleries = galleries.sorted({ (gallery1, gallery2) -> Bool in
            let gallery1Location = CLLocation(latitude: gallery1.latitude, longitude: gallery1.longitude)
            let gallery2Location = CLLocation(latitude: gallery2.latitude, longitude: gallery2.longitude)
            let gallery1ToCurrent = gallery1Location.distanceFromLocation(currentLocation)
            let gallery2ToCurrent = gallery2Location.distanceFromLocation(currentLocation)
            
            return gallery1ToCurrent < gallery2ToCurrent
        })
        
        self.tableView.reloadData()
    }
    
    // MARK: - Segue
    
    func handleGalleryTab(sender: GalleryCell) {
        performSegueWithIdentifier(Segue.ShowGalleryProfile.rawValue, sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Segue.ShowGalleryProfile.rawValue {
            var controller = segue.destinationViewController as GalleryProfileViewController
            var cell = sender as GalleryCell
            controller.gallery = cell.gallery
        }
    }
}

