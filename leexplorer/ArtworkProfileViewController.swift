//
//  ArtworkViewController.swift
//  leexplorer
//
//  Created by Hector Monserrate on 26/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import UIKit

class ArtworkProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var playButton: MKButton!
    @IBOutlet var playIcon: UIImageView!
    @IBOutlet var mediaPlayerView: MediaPlayerView!
    @IBOutlet var mediaPlayerBottomConstraint: NSLayoutConstraint!
    
    
    let HEADER_HEIGHT: CGFloat = 220.0
    var artwork: Artwork!
    var headerOriginalWidth: CGFloat!
    var profileHeaderView: ArtworkProfileHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = artwork.name
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        edgesForExtendedLayout = .None;
        
        setupTableView()
        setupPlayButton()
        setupMediaPlayerView()
    }
    
    // MARK - Setup Views
    
    func setupMediaPlayerView() {
        mediaPlayerView.duration = 165.001
        mediaPlayerView.currentPosition = 0.0
        mediaPlayerView.tintColor = ColorPallete.Blue.get()
        
        if !MediaPlayerService.shared.isPlayingArtwork(artwork) {
            mediaPlayerBottomConstraint.constant = -1 * mediaPlayerView.bounds.height
        }
    }
    
    func setupPlayButton() {
        playIcon.tintColor = ColorPallete.White.get()
        playButton.cornerRadius = 40.0
        playButton.backgroundLayerCornerRadius = 40.0
        playButton.maskEnabled = false
        playButton.circleGrowRatioMax = 1.75
        playButton.rippleLocation = .Center
        playButton.aniDuration = 0.85
        playButton.tintColor = ColorPallete.Blue.get()
        
        playButton.layer.shadowOpacity = 0.75
        playButton.layer.shadowRadius = 3.5
        playButton.layer.shadowColor = UIColor.blackColor().CGColor
        playButton.layer.shadowOffset = CGSize(width: 1.0, height: 5.5)
        
        playButton.hidden = MediaPlayerService.shared.isPlayingArtwork(artwork) || artwork.audio == nil
    }
    
    func setupTableView() {
        let cellNib = UINib(nibName: "ProfileSectionCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "ProfileSectionCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        headerOriginalWidth = view.frame.width
        let headerFrame = CGRectMake(0, 0, headerOriginalWidth, HEADER_HEIGHT)
        profileHeaderView = ArtworkProfileHeaderView(frame: headerFrame)
        profileHeaderView.artwork = artwork
        profileHeaderView.userInteractionEnabled = false
        self.view.addSubview(profileHeaderView)
        
        let transparentView = UIView(frame: headerFrame)
        transparentView.backgroundColor = UIColor.clearColor()
        tableView.tableHeaderView = transparentView
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = tableView.contentOffset.y
        
        profileHeaderView.blur(offset, headerHeight: HEADER_HEIGHT)
    }
    
    // MARK - UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileSectionCell", forIndexPath: indexPath) as ProfileSectionCell
        
        cell.title = NSLocalizedString("DESCRIPTION", comment: "")
        cell.sectionText = artwork.desc
        
        return cell
    }
    
    @IBAction func didTabPlay(sender: AnyObject) {
//        MediaPlayerService.shared.playArtwork(artwork)
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.playButton.alpha = 0.0
        }) { (_) -> Void in
           self.playButton.hidden = true
        }
        
        UIView.animateWithDuration(1.0, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
            self.mediaPlayerBottomConstraint.constant = 0
            self.mediaPlayerView.layoutIfNeeded()
        }, completion: nil)

        
    }


}
