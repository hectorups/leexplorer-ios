//
//  ViewController.swift
//  leexplorer
//
//  Created by Hector Monserrate on 24/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import UIKit

class GalleryListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GalleryCellDelegate {

    @IBOutlet var tableView: UITableView!
    
    let GALLERY_CELL_HEIGHT: CGFloat = 240
    
    var galleries: [Gallery] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("GALLERY_LIST_TITLE", comment: "")
        
        setupTableView()
        loadGalleries()
    }
    
    func setupTableView() {
        tableView.backgroundColor = ColorPallete.AppBg.get()
        tableView.delegate = self
        tableView.dataSource = self
        
        let cellNib = UINib(nibName: "GalleryCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "GalleryCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    func loadGalleries() {
        self.galleries = Gallery.allGalleries()
        self.tableView.reloadData()
//        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
//        LeexplorerApi.shared.getGalleries({ (galleries) -> Void in
//            LELog.d(galleries.count)
//            self.galleries = galleries
//            self.tableView.reloadData()
//            MBProgressHUD.hideHUDForView(self.view, animated: true)
//        }, failure: { (operation, error) -> Void in
//            LELog.e(error)
//            MBProgressHUD.hideHUDForView(self.view, animated: true)
//        })
    }
    
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

