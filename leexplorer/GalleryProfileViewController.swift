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
    @IBOutlet var exploreCollectionButton: MKButton!
    @IBOutlet weak var downloadButton: MKButton!
    @IBOutlet weak var downloadIcon: UIImageView!
    
    var gallery: Gallery!
    
    private var profileHeaderView: GalleryProfileHeaderView!
    private var headerOriginalWidth: CGFloat!
    private var notificationManager = NotificationManager()
    
    let HEADER_HEIGHT: CGFloat = 260.0
    var waitingForShareImage = false
    var shareImageView: UIImageView?
    
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
        
        view.backgroundColor = ColorPallete.AppBg.get()
        title = gallery.name
        edgesForExtendedLayout = .None;
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        setupDownload()
        setupShare()
        setupTableView()
        setupExploreCollectionButton()
        setupNotifications()
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
    
    // MARK: - Setup 
    
    func setupDownload() {
        downloadIcon.fixTemplateImage()
        downloadIcon.tintColor = ColorPallete.White.get()
        downloadButton.cornerRadius = 40.0
        downloadButton.backgroundLayerCornerRadius = 40.0
        downloadButton.maskEnabled = false
        downloadButton.circleGrowRatioMax = 1.75
        downloadButton.rippleLocation = .Center
        downloadButton.aniDuration = 0.85
        downloadButton.fixTemplateImage()
        downloadButton.tintColor = ColorPallete.Blue.get()
        
        downloadButton.layer.shadowOpacity = 0.65
        downloadButton.layer.shadowRadius = 2.5
        downloadButton.layer.shadowColor = UIColor.blackColor().CGColor
        downloadButton.layer.shadowOffset = CGSize(width: 1.0, height: 3.5)
        
    }
    
    func setupNotifications() {
        notificationManager.registerObserverType(.DownloadProgress) { [weak self] (notification) -> Void in
            if let strongSelf = self {
                let galleryId = notification.userInfo!["galleryId"] as String
                let progress = notification.userInfo!["progress"] as Float
                
                if galleryId == strongSelf.gallery.id {
                    strongSelf.downloadProgress(progress)
                }
            }
        }
    }
    
    func setupShare() {
        let shareIcon = UIImage(named: "share_icon")?.fixTemplateImage()
        
        var rightBarButtonItem = UIBarButtonItem()
        rightBarButtonItem.image = shareIcon
        rightBarButtonItem.tintColor = ColorPallete.Blue.get()
        rightBarButtonItem.target = self
        rightBarButtonItem.action = "didTabShare"
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        let shareImageUrl = MediaProcessor.urlForImageFill(gallery.images.firstObject() as Image, width: Int(200), height: Int(200))
        shareImageView = UIImageView()
        shareImageView!.setImageWithURLRequest(NSURLRequest(URL: shareImageUrl),
            placeholderImage: nil,
            success: { (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) in
                self.shareImageView!.image = image
                if self.waitingForShareImage {
                    self.didTabShare()
                }
            },
            failure: { (request: NSURLRequest!, response: NSHTTPURLResponse!, error: NSError!) in
                LELog.e(error.description)
        })
    }
    
    func setupExploreCollectionButton() {
        exploreCollectionButton.backgroundColor = ColorPallete.Blue.get().colorWithAlphaComponent(0.95)
        exploreCollectionButton.titleLabel?.text = NSLocalizedString("EXPLORE_COLLECTION", comment: "")
        exploreCollectionButton.maskEnabled = true
        exploreCollectionButton.rippleLocation = .TapLocation
        exploreCollectionButton.circleLayerColor = ColorPallete.Blue.get()
    }
    
    func setupTableView() {
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
        tableView.backgroundColor = ColorPallete.AppBg.get()
    }

    // MARK: - Table view data source

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section.count()
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSectionCell", forIndexPath: indexPath) as ProfileSectionCell
        cell.backgroundColor =  ColorPallete.AppBg.get()
        let section = Section(rawValue: indexPath.item)!
        cell.title = section.title()
        cell.sectionText = section.text(gallery)

        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = Section(rawValue: indexPath.item)!
        
        return ProfileSectionCell.heightWithText(section.text(gallery))
    }
    
    // MARK: - Share
    
    func didTabShare() {
        if shareImageView?.image == nil {
            waitingForShareImage = true
            progressStartAnimating()
            return
        }
        
        let shareableContent = OSKShareableContent(fromImages: [shareImageView!.image!], caption: gallery.name)
        OverShareHelper.sharedInstance().presentActivitySheetForContent(shareableContent, presentingViewController: self)
        
        if waitingForShareImage {
            waitingForShareImage = false
            progressStopAnimating()
        }
    }
    
    // MARK: - Download
    
    func downloadProgress(progress: Float) {
        println("download progress: \(progress)")
    }

    @IBAction func didTabDownload(sender: AnyObject) {
        DownloadService(gallery: gallery).download()
    }
}
