//
//  ViewController.swift
//  leexplorer
//
//  Created by Hector Monserrate on 24/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import UIKit

class GalleryListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    let GALLERY_CELL_HEIGHT: CGFloat = 300
    
    var galleries: [String] = ["asian museum", "bam museum", "picasso"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setupTableView()
    }
    
    func setupTableView() {
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
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return GALLERY_CELL_HEIGHT
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("GalleryCell") as GalleryCell
        cell.gallery = self.galleries[indexPath.row]
        return cell
    }
}

