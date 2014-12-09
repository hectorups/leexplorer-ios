//
//  LocalSource.swift
//  leexplorer
//
//  Created by Hector Monserrate  on 12/8/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation


class MediaManager {
    
    enum Size {
        case Large,
        Medium,
        Small
        
        func width() -> CGFloat {
            let width = UIScreen.mainScreen().bounds.width
            switch self {
            case .Large:
                return 1.6 * width
            case .Medium:
                return 1 * width
            case .Small:
                return 0.5 * width
            }
        }
        
        func height() -> CGFloat {
            let height = UIScreen.mainScreen().bounds.height
            switch self {
            case .Large:
                return 1.6 * height
            case .Medium:
                return 0.7 * height
            case .Small:
                return 0.5 * height
            }
        }
        
        static let allValues = [Large, Medium, Small]
    }
    
    class func localUrlForImage(image: Image, size: Size, galleryId: String) -> String? {
        let name = imageName(image, size: size)
        return TWRDownloadManager.sharedManager().localPathForFile(name, inDirectory: folderFromGalleryId(galleryId))
    }
    
    class func folderFromGalleryId(galleryId: String) -> String {
        return galleryId
    }
    
    class func imageExists(image: Image, size: Size, galleryId: String) -> Bool {
        let name = imageName(image, size: size)
        return TWRDownloadManager.sharedManager().fileExistsWithName(name, inDirectory: folderFromGalleryId(galleryId))
    }
    
    class func imageName(image: Image, size: Size) -> String {
        var name = imageUrl(image, size: size).lastPathComponent
        
        if size == .Small {
            name = "small_\(name)"
        } else if size == .Medium {
            name = "medium_\(name)"
        }
        
        return name
    }
    
    class func imageUrl(image: Image, size: Size) -> String {
        let bounds = UIScreen.mainScreen().bounds
        let url = MediaProcessor.urlForImageFill(image,
            width: Int(size.width()),
            height: Int(size.height()),
            scaleForDevice: true).absoluteString!
        
        return url
    }
    
    class func audioUrl(audio: Audio) -> String {
        return MediaProcessor.urlForAudio(audio).absoluteString!
    }
    
    class func audioName(audio: Audio) -> String {
        return audioUrl(audio).lastPathComponent
    }
}