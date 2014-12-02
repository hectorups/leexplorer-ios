//
//  ArtworkViewController.swift
//  leexplorer
//
//  Created by Hector Monserrate on 26/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import UIKit

class ArtworkProfileViewController: UIViewController, UITableViewDelegate,
    UITableViewDataSource, MediaPlayerViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var playButton: MKButton!
    @IBOutlet var playIcon: UIImageView!
    @IBOutlet var mediaPlayerView: MediaPlayerView!
    @IBOutlet var mediaPlayerBottomConstraint: NSLayoutConstraint!
    
    
    let HEADER_HEIGHT: CGFloat = 260.0
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
        
        setupNotifications()
    }
    
    // MARK - Setup Views
    
    func setupMediaPlayerView() {
        mediaPlayerView.currentPosition = 0.0
        mediaPlayerView.tintColor = ColorPallete.Blue.get()
        mediaPlayerView.delegate = self
        
        if !MediaPlayerService.shared.isPlayingArtwork(artwork) {
            mediaPlayerBottomConstraint.constant = -1 * mediaPlayerView.bounds.height
        } else {
            mediaPlayerView.paused = MediaPlayerService.shared.paused
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
        playIcon.hidden = playButton.hidden
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
    
    // MARK - Setup Notifications
    
    func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserverForName(AppNotification.AudioProgressUpdate.rawValue, object: nil, queue: nil) { [weak self] (notification) -> Void in
            var time = notification.userInfo!["time"] as Float
            var duration = notification.userInfo!["duration"] as Float
            if let strongSelf = self {
                if MediaPlayerService.shared.isPlayingArtwork(strongSelf.artwork) {
                    strongSelf.showMediaPlayerTime(time, duration: duration)
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(AppNotification.AudioCompleted.rawValue, object: nil, queue: nil) { [weak self] (notification) -> Void in
            var artworkId = notification.userInfo!["artworkId"] as String
            if let strongSelf = self {
                if MediaPlayerService.shared.isPlayingArtwork(strongSelf.artwork) {
                    strongSelf.mediaPlayerAudioCompleted()
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(AppNotification.AudioPaused.rawValue, object: nil, queue: nil) { [weak self] (notification) -> Void in
            var artworkId = notification.userInfo!["artworkId"] as String
            if let strongSelf = self {
                if MediaPlayerService.shared.isPlayingArtwork(strongSelf.artwork) {
                    strongSelf.mediaPlayerAudioPaused()
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(AppNotification.AudioResumed.rawValue, object: nil, queue: nil) { [weak self] (notification) -> Void in
            var artworkId = notification.userInfo!["artworkId"] as String
            if let strongSelf = self {
                if MediaPlayerService.shared.isPlayingArtwork(strongSelf.artwork) {
                    strongSelf.mediaPlayerAudioResumed()
                }
            }
        }
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
    
    // MARK - Audio control
    
    
    @IBAction func didTabPlay(sender: AnyObject) {
        MediaPlayerService.shared.playArtwork(artwork)
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.playButton.alpha = 0.0
            self.playIcon.alpha = 0.0
        }) { (_) -> Void in
            self.playButton.hidden = true
            self.playIcon.hidden = self.playButton.hidden
        }
    }
    
    func showMediaPlayerTime(time: Float, duration: Float) {
        self.mediaPlayerView.currentPosition = time
        self.mediaPlayerView.duration = duration
        
        if mediaPlayerBottomConstraint.constant != 0 {
            UIView.animateWithDuration(1.0, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
                self.mediaPlayerBottomConstraint.constant = 0
                self.mediaPlayerView.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func mediaPlayerAudioCompleted() {
        self.mediaPlayerView.currentPosition = 0.0
    }
    
    func mediaPlayerAudioPaused() {
        self.mediaPlayerView.paused = true
    }
    
    func mediaPlayerAudioResumed() {
        self.mediaPlayerView.paused = false
    }
    
    // MARK - MediaPlayerViewDelegate
    
    func mediaPlayerView(mediaPlayerView: MediaPlayerView, play: Bool) {
        if !MediaPlayerService.shared.isPlayingArtwork(artwork) {
            if play {
                MediaPlayerService.shared.playArtwork(artwork)
            }
            return
        }
        
        if play {
            MediaPlayerService.shared.play()
        } else {
            MediaPlayerService.shared.pause()
        }
    }
    
    func mediaPlayerView(mediaPlayerView: MediaPlayerView, updatedValue: Float) {
        if !MediaPlayerService.shared.isPlayingArtwork(artwork) {
            return
        }
        
        MediaPlayerService.shared.seekToTime(updatedValue)
    }

}
