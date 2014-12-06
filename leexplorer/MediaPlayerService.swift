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
    private var artwork: Artwork?
    private var playbackObserver: AnyObject?
    private var readyToCheck = false
    private var notificationManager: NotificationManager
    
    var paused = false
    
    class var shared : MediaPlayerService {
        struct Static {
            static let instance = MediaPlayerService()
        }
        return Static.instance
    }
    
    override init() {
        notificationManager = NotificationManager()
        super.init()
        
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        session.setActive(true, error: nil)
        session.overrideOutputAudioPort(.None, error: nil)

        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }
    
    func playArtwork(artwork: Artwork) {
        var error: NSError?
        
        if audioPlayer != nil {
            stop()
        }
        
        let url = MediaProcessor.urlForAudio(artwork.audio!)
        LELog.d(url)
        
        self.artwork = artwork
        
        playerItem = AVPlayerItem(URL: url)
        notificationManager.registerObserverName(AVPlayerItemDidPlayToEndTimeNotification, forObject: playerItem!) {[weak self] (notification) -> Void in
            LELog.d("Audio finished playing")
            if let strongSelf = self {
                let data = ["artworkId": strongSelf.artwork!.id]
                NSNotificationCenter.defaultCenter().postNotificationName(AppNotification.AudioCompleted.rawValue, object: strongSelf, userInfo: data)
                strongSelf.stop()
            }
        }
        
        playerItem!.addObserver(self, forKeyPath: "status", options: nil, context: &itemStatusContext)
        
        audioPlayer = AVPlayer(playerItem: playerItem)
        play()
    }
    
    func hasArtworkTrack() -> Bool {
        return artwork != nil
    }
    
    func play() {
        LELog.d("MediaPlayerService Play")
        paused = false
        audioPlayer?.play()
        
        let data = ["artworkId": self.artwork!.id]
        NSNotificationCenter.defaultCenter().postNotificationName(AppNotification.AudioResumed.rawValue, object: self, userInfo: data)
    }
    
    func pause() {
        LELog.d("MediaPlayerService Pause")
        paused = true
        audioPlayer?.pause()
        
        let data = ["artworkId": self.artwork!.id]
        NSNotificationCenter.defaultCenter().postNotificationName(AppNotification.AudioPaused.rawValue, object: self, userInfo: data)
    }
    
    func stop() {
        LELog.d("MediaPlayerService Stop")
        pause()
        playerItem?.removeObserver(self, forKeyPath: "status", context: &itemStatusContext)
        if let observer: AnyObject = self.playbackObserver {
            audioPlayer?.removeTimeObserver(observer)
        }
        notificationManager.deregisterAll()
        
        readyToCheck = false
        audioPlayer = nil
        playerItem = nil
        playbackObserver = nil
        artwork = nil
    }
    
    
    func seekToTime(time: Float) {
        var cmtime = CMTimeMakeWithSeconds(Float64(time), 1)
        playerItem?.seekToTime(cmtime)
    }
    
    func isAvailable() -> Bool {
        return artwork == nil
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
                NSNotificationCenter.defaultCenter().postNotificationName(AppNotification.AudioStarted.rawValue, object: self, userInfo: ["artworkId": artwork!.id])
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
//            MPNowPlayingInfoPropertyPlaybackRate: 1.0,
            MPMediaItemPropertyPlaybackDuration: CMTimeGetSeconds(self.currentTrackDuration())
        ]
        
        trackTime()
        
        //        [audioInfo setObject:[[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithData:_artwork.artworkImage]] forKey:MPMediaItemPropertyArtwork];
    }
    
    private func trackTime() {
        let interval = CMTimeMake(1, 2);
        readyToCheck = true
        playbackObserver = audioPlayer?.addPeriodicTimeObserverForInterval(interval, queue: nil, usingBlock: { [weak self] (time) -> Void in
            if let strongSelf = self {
                if !strongSelf.readyToCheck {
                    return
                }
                
                let time = Float(CMTimeGetSeconds(strongSelf.playerItem!.currentTime()))
                let duration = Float(CMTimeGetSeconds(strongSelf.currentTrackDuration()))
                let rate = strongSelf.paused ? 0.0 : 1.0
                //LELog.d("Time: \(time) of \(duration)")
                
                var playingInfo = NSMutableDictionary(dictionary: MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo)
                playingInfo.setValue(time, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
                playingInfo.setValue(rate, forKey: MPNowPlayingInfoPropertyPlaybackRate)
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = playingInfo
                
                let data = [
                    "time": time,
                    "duration": duration,
                    "artworkId": strongSelf.artwork!.id
                ]
                NSNotificationCenter.defaultCenter().postNotificationName(AppNotification.AudioProgressUpdate.rawValue, object: strongSelf, userInfo: data)
            }
        })
    }
    
    
}