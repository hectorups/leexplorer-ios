//
//  DownloadService.swift
//  leexplorer
//
//  Created by Hector Monserrate  on 12/7/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

class DownloadService {
    
    let LARGE_IMAGE_FACTOR: CGFloat = 2.0
    let SMALL_IMAGE_FACTOR: CGFloat = 0.5
    
    var gallery: Gallery
    
    init(gallery: Gallery) {
        self.gallery = gallery
    }
    
    func download() {
        LeexplorerApi.shared.getGalleryArtworks(gallery, success: { (artworks) -> Void in
            self.downloadArtworks(artworks)
        }) { (operation, error) -> Void in
            LELog.e("error loading gallery artworks \(error)")
        }
    }
    
    func downloaded(artworks: [Artwork]) -> Bool {
        let urls = artworksMediaUrls(artworks)
        for (name,url) in urls {
            println("Check file url \(url)")
            if !TWRDownloadManager.sharedManager().fileExistsWithName(name, inDirectory: folder()){
                return false
            }
        }
        
        return true
    }
    
    private func downloadArtworks(artworks: [Artwork]) {
        createFolder(folder())
        let urls = artworksMediaUrls(artworks)
        
        for (name,url) in urls {
            downloadUrl(url, withName: name)
        }
    }
    
    private func artworksMediaUrls(artworks: [Artwork]) -> [String:String] {
        var urls: [String : String] = [:]
        for artwork in artworks {
            urls[imageName(artwork.image, factor: LARGE_IMAGE_FACTOR)] = imageUrl(artwork.image, factor: LARGE_IMAGE_FACTOR)
            urls[imageName(artwork.image, factor: SMALL_IMAGE_FACTOR)] = imageUrl(artwork.image, factor: SMALL_IMAGE_FACTOR)
            
            if let audio = artwork.audio {
                urls[audioName(audio)] = audioUrl(audio)
            }
        }
        
        return urls
    }
    
    private func imageUrl(image: Image, factor: CGFloat) -> String {
        let bounds = UIScreen.mainScreen().bounds
        let url = MediaProcessor.urlForImageFill(image,
            width: Int(bounds.width * factor),
            height: Int(bounds.height * factor),
            scaleForDevice: true).absoluteString!
        
        return url
    }
    
    private func imageName(image: Image, factor: CGFloat) -> String {
        var name = imageUrl(image, factor: factor).lastPathComponent
        
        if factor == SMALL_IMAGE_FACTOR {
            name = "small_\(name)"
        }
        
        return name
    }
    
    private func audioUrl(audio: Audio) -> String {
        return MediaProcessor.urlForAudio(audio).absoluteString!
    }
    
    private func audioName(audio: Audio) -> String {
        return audioUrl(audio).lastPathComponent
    }
    
    private func downloadUrl(url: String, withName: String) {
        LELog.d("Downloading \(url) to \(folder)")
        TWRDownloadManager.sharedManager().downloadFileForURL(url, withName: withName,inDirectoryNamed: folder(), progressBlock: { (progress) -> Void in
            LELog.d("\(progress) \(url)")
        }, completionBlock: { (completed) -> Void in
            LELog.d("Competed \(url)")
        }, enableBackgroundMode: true)
    }
    
    private func folder() -> String {
        return gallery.id
    }
    
    func createFolder(name: String) -> NSURL? {
        let fm = NSFileManager.defaultManager()
        var dirPath: NSURL? = nil
        
        var appSupportDir = fm.URLsForDirectory(NSSearchPathDirectory.CachesDirectory, inDomains: .UserDomainMask)
        if let supportDir = appSupportDir.first as? NSURL {
            dirPath = supportDir.URLByAppendingPathComponent(name)
            LELog.d("create: \(dirPath)")
            var theError = NSErrorPointer()
            if !fm.createDirectoryAtURL(dirPath!, withIntermediateDirectories: true, attributes: nil, error: theError) {
                LELog.e(theError.debugDescription)
                return nil
            }
        } else {
            return nil
        }
     
        return dirPath
    }
}