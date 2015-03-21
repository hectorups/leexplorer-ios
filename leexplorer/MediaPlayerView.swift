//
//  MediaPlayerView.swift
//  leexplorer
//
//  Created by Hector Monserrate on 01/12/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

protocol MediaPlayerViewDelegate: class {
    func mediaPlayerView(mediaPlayerView: MediaPlayerView, play: Bool)
    func mediaPlayerView(mediaPlayerView: MediaPlayerView, updatedValue: Float)
}

class MediaPlayerView: NibDesignable {
    @IBOutlet var playButton: UIButton!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var currentPositionLabel: UILabel!
    @IBOutlet var progressSlider: UISlider!
    weak var delegate: MediaPlayerViewDelegate?
    
    var duration: Float! {
        didSet {
            durationLabel.text = timeFormat(duration)
            progressSlider.maximumValue = duration
        }
    }
    
    var currentPosition: Float! {
        didSet {
            currentPositionLabel.text = timeFormat(currentPosition)
            if !editing {
                self.progressSlider.value = self.currentPosition
            }
        }
    }
    
    var paused: Bool! {
        didSet {
            var imageName = "pause_icon";
            if let paused = self.paused{
                if paused {
                    imageName = "play_icon"
                }
            }
            
            let image = UIImage(named: imageName) as UIImage?
            playButton.setImage(image!.fixTemplateImage(), forState: .Normal)
            playButton.tintColor = ColorPallete.Blue.get()
            
        }
    }
    
    private var editing = false
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        progressSlider.tintColor = self.tintColor
        
        if NSClassFromString("UIBlurEffect") != nil && SDKVersion.greaterOrEqualTo("8.0") {
            blurBg()
        } else {
            self.backgroundColor = ColorPallete.White.get()
        }
    }
    
    private func blurBg() {
        self.backgroundColor = ColorPallete.Clear.get()
        let blurEffect = UIBlurEffect(style: .Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.insertSubview(blurView, atIndex: 0)
        
        let viewsDictionary = ["view": blurView]
        let view1_constraint_H = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        let view1_constraint_V = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        self.addConstraints(view1_constraint_H)
        self.addConstraints(view1_constraint_V)
    }
    
    
    private func timeFormat(value: Float) -> String {
        let minutes = floor(Float(lroundf(value)) / 60.0)
        let seconds = Float(lroundf(value)) - (minutes * 60)
        
        let roundedMinutes = lroundf(minutes)
        let roundedSeconds = lroundf(seconds)
        
        return NSString(format: "%ld:%02ld", roundedMinutes, roundedSeconds)
    }
    
    @IBAction func didTabPlayButton(sender: AnyObject) {
        delegate?.mediaPlayerView(self, play: paused)
    }
    
    @IBAction func didTouchUp(sender: AnyObject) {
        delegate?.mediaPlayerView(self, updatedValue: progressSlider.value)
        editing = false
    }
    
    @IBAction func didTouchDown(sender: AnyObject) {
        editing = true
    }
    
}