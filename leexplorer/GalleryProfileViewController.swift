//
//  GalleryTableViewController.swift
//  leexplorer
//
//  Created by Hector Monserrate on 25/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import UIKit

class GalleryProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var gallery: Gallery!
    var profileHeaderView: GalleryProfileHeaderView!
    var headerOriginalWidth: CGFloat!
    @IBOutlet var exploreCollectionButton: MKButton!
    
    let HEADER_HEIGHT: CGFloat = 260.0
    
    enum Section: Int {
        case Hours=0, Price, Description
        
        func title() -> String {
            switch self {
            case .Hours:
                return NSLocalizedString("HOURS", comment: "")
            case .Price:
                return NSLocalizedString("PRICE", comment: "")
            case .Description:
                return NSLocalizedString("DESCRIPTION", comment: "")
            }
        }
        
        func text(gallery: Gallery) -> String {
            switch self {
            case .Hours:
                return gallery.hours
            case .Price:
                return gallery.priceDescription
            case .Description:
                return gallery.desc
            }
        }
        
        static func count() -> Int {
            return 3
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = gallery.name
        edgesForExtendedLayout = .None;
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        let cellNib = UINib(nibName: "ProfileSectionCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "ProfileSectionCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        headerOriginalWidth = view.frame.width
        let headerFrame = CGRectMake(0, 0, headerOriginalWidth, HEADER_HEIGHT)
        profileHeaderView = GalleryProfileHeaderView(frame: headerFrame)
        profileHeaderView.gallery = gallery
        profileHeaderView.userInteractionEnabled = false
        self.view.addSubview(profileHeaderView)
        
        let transparentView = UIView(frame: headerFrame)
        transparentView.backgroundColor = UIColor.clearColor()
        tableView.tableHeaderView = transparentView
        let transparentFooterView = UIView(frame: exploreCollectionButton.frame)
        transparentFooterView.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = transparentFooterView
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        
        exploreCollectionButton.backgroundColor = ColorPallete.Blue.get().colorWithAlphaComponent(0.95)
        exploreCollectionButton.titleLabel?.text = NSLocalizedString("EXPLORE_COLLECTION", comment: "")
        exploreCollectionButton.maskEnabled = true
        exploreCollectionButton.rippleLocation = .TapLocation
        exploreCollectionButton.circleLayerColor = ColorPallete.Blue.get()
    }


    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = tableView.contentOffset.y
        
        profileHeaderView.blur(offset, headerHeight: HEADER_HEIGHT)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Segue.ShowArtworkList.rawValue {
            var controller = segue.destinationViewController as ArtworkListViewController
            controller.gallery = gallery
        }
    }

    // MARK: - Table view data source

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section.count()
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSectionCell", forIndexPath: indexPath) as ProfileSectionCell
        
        let section = Section(rawValue: indexPath.item)!
        cell.title = section.title()
        cell.sectionText = section.text(gallery)

        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = Section(rawValue: indexPath.item)!
        
        return ProfileSectionCell.heightWithText(section.text(gallery))
    }

}
