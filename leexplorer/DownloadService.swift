//
//  DownloadService.swift
//  leexplorer
//
//  Created by Hector Monserrate  on 12/7/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

class DownloadService {
    
    var gallery: Gallery
    var completed: Int = 0
    var total: Int?
    
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
            if !TWRDownloadManager.sharedManager().fileExistsWithName(name, inDirectory: folder()) {
                return false
            }
        }
        
        return true
    }
    
    
    private func downloadArtworks(artworks: [Artwork]) {
        createFolder(folder())
        let urls = artworksMediaUrls(artworks)
        total = urls.count
        for (name, url) in urls {
            if !TWRDownloadManager.sharedManager().fileExistsWithName(name, inDirectory: folder()) {
                downloadUrl(url, withName: name)
            } else {
                completed++
            }
        }
        
        if completed == total {
            notifyProgress()
        }
    }
    
    private func artworksMediaUrls(artworks: [Artwork]) -> [String:String] {
        var urls: [String : String] = [:]
        for artwork in artworks {
            for size in MediaManager.Size.allValues {
                urls[MediaManager.imageName(artwork.image, size: size)] = MediaManager.imageUrl(artwork.image, size: size)
            }
            
            if let audio = artwork.audio {
                urls[MediaManager.audioName(audio)] = MediaManager.audioUrl(audio)
            }
        }
        
        return urls
    }
    
    private func downloadUrl(url: String, withName: String) {
        LELog.d("Downloading \(url) to \(folder)")
        TWRDownloadManager.sharedManager().downloadFileForURL(url, withName: withName,inDirectoryNamed: folder(), progressBlock: { (progress) -> Void in
            self.notifyProgress()
        }, completionBlock: { (completed) -> Void in
            LELog.d("Competed \(url)")
            self.completed++
            self.notifyProgress()
        }, enableBackgroundMode: true)
    }
    
    private func folder() -> String {
        return MediaManager.folderFromGalleryId(gallery.id)
    }
    
    private func notifyProgress() {
        let progress: Float = Float(completed) / Float(total!)
        if progress == 1.0 {
            gallery.setDownloadedAt(NSDate())
        }
        
        let data = ["galleryId": gallery.id , "progress": progress ]
        NSNotificationCenter.defaultCenter().postNotificationName(AppNotification.DownloadProgress.rawValue,
            object: self, userInfo: data)
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