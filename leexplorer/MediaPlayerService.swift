//
//  MediaPlayerService.swift
//  leexplorer
//
//  Created by Hector Monserrate on 29/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class MediaPlayerService: NSObject {
    
    private var itemStatusContext = 0
    
    private var audioPlayer: AVPlayer?
    private var playerItem: AVPlayerItem?
    var artwork: Artwork?
    var playbackObserver: AnyObject?
    
    class var shared : MediaPlayerService {
        struct Static {
            static let instance = MediaPlayerService()
        }
        return Static.instance
    }
    
    override init() {
        var session = AVAudioSession.sharedInstance()

        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        session.setActive(true, error: nil)
        session.overrideOutputAudioPort(.None, error: nil)
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }
    
    func playArtwork(artwork: Artwork) {
        var error: NSError?
        
        let url = MediaProcessor.urlForAudio(artwork.audio!)
        LELog.d(url)
        
        self.artwork = artwork
        playerItem = AVPlayerItem(URL: url)
        NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: playerItem!, queue: nil) { (notification) -> Void in
            LELog.d("Audio finished playing")
            if let observer: AnyObject = self.playbackObserver {
                self.audioPlayer?.removeTimeObserver(observer)
            }
        }
        
        playerItem!.addObserver(self, forKeyPath: "status", options: nil, context: &itemStatusContext)
        
        audioPlayer = AVPlayer(playerItem: playerItem)
        audioPlayer!.play()
        
    }
    
    func play() {
        audioPlayer?.play()
    }
    
    func pause() {
        audioPlayer?.pause()
    }
    
    
    func seekToTime(time: CMTime) {
        audioPlayer?.seekToTime(time)
    }

    func isPlaying() -> Bool {
        if let audioPlayer = self.audioPlayer {
            return audioPlayer.rate > 0 && audioPlayer.error != nil
        } else {
            return false
        }
    }
    
    func currentTrackDuration() -> CMTime {
        return playerItem!.tracks.first!.assetTrack!.asset.duration
    }
    
    func isPlayingArtwork(artwork: Artwork) -> Bool {
        if let playingArtwork = self.artwork {
            if playingArtwork == artwork {
                return true
            }
        }
        
        return false
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &itemStatusContext {
            switch playerItem!.status {
            case .ReadyToPlay:
                LELog.d("Ready to play")
                trackAudio()
            default:
                LELog.d("Status change for audioplayer")
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // MARK - Private MediaPlayerService
    
    private func trackAudio() {
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
            MPMediaItemPropertyArtist: artwork!.author ?? "unknown",
            MPMediaItemPropertyTitle: artwork!.name,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0,
            MPMediaItemPropertyPlaybackDuration: CMTimeGetSeconds(self.currentTrackDuration())
        ]
        
        trackTime()
        
        //        [audioInfo setObject:[[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithData:_artwork.artworkImage]] forKey:MPMediaItemPropertyArtwork];
    }
    
    private func trackTime() {
        let interval = CMTimeMake(1, 1);
        playbackObserver = audioPlayer?.addPeriodicTimeObserverForInterval(interval, queue: nil, usingBlock: { (time) -> Void in
            let time = CMTimeGetSeconds(self.audioPlayer!.currentTime());
            let total = CMTimeGetSeconds(self.currentTrackDuration())
            LELog.d("Time: \(time) of \(total)")
        })
    }
    
}