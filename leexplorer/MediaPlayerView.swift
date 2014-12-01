//
//  MediaPlayerView.swift
//  leexplorer
//
//  Created by Hector Monserrate on 01/12/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

class MediaPlayerView: NibDesignable {
    @IBOutlet var playButton: UIButton!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var currentPositionLabel: UILabel!
    @IBOutlet var progressSlider: UISlider!
    
    var duration: Float! {
        didSet {
            durationLabel.text = timeFormat(duration)
            progressSlider.maximumValue = duration
        }
    }
    
    var currentPosition: Float! {
        didSet {
            currentPositionLabel.text = timeFormat(currentPosition)
            progressSlider.value = currentPosition
        }
    }
    
    override func tintColorDidChange() {
        progressSlider.tintColor = self.tintColor
        
        if (NSClassFromString("UIBlurEffect") != nil) {
            blurBg()
        }
        else {
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
}