//
//  ImageProcessor.swift
//  leexplorer
//
//  Created by Hector Monserrate on 25/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

class ImageProcessor {
    
    class var shared : CLCloudinary {
        struct Static {
            static let instance = CLCloudinary()
        }
        Static.instance.config().setValue(AppConstant.CLOUDINARY_CLOUD_NAME, forKey: "cloud_name")
        return Static.instance
    }
    
    enum Crop: String {
       case LFILL="lfill",
        FIT="fit",
        LIMIT="limit"
    }
    
    enum Format: String {
        case JPG="jpg",
            WEBP="webp"
    }
    
    
    // MARK: ImageProcessor
    
    class func urlForImageFill(image: Image, width: Int, height: Int, scaleForDevice: Bool = true) -> NSURL {
        return urlForImage(image, width: width, height: height, crop: .LFILL, scaleForDevice: scaleForDevice)
    }
    
    class func urlForImageFit(image: Image, containerSize: CGSize, imageSize: CGSize, scaleForDevice: Bool) -> NSURL {
        var scaledContainerSize = scaleForDevice ? scaledSizeForSize(containerSize) : containerSize
        var height = Int(fmin(scaledContainerSize.height, imageSize.height))
        var width = Int(fmin(scaledContainerSize.width, imageSize.width))
        
        return urlForImage(image, width: width, height: height, crop: .FIT, scaleForDevice: false)
    }
    
    class func urlForImage(image: Image, width: Int, height: Int, crop: Crop, scaleForDevice: Bool = true) -> NSURL {
        var scale = scaleForDevice ? Int(UIScreen.mainScreen().scale) : 1
        var transformation = CLTransformation.transformation() as CLTransformation
        transformation.setWidthWithInt(Int32(width * scale))
        transformation.setHeightWithInt(Int32(height * scale))
        transformation.crop = crop.rawValue
        
        let format = Format.JPG.rawValue
        let url = shared.url("\(image.publicId).\(format)", options: ["transformation": transformation])
        
        return NSURL(string: url)!
    }
    
    
    class func scaledSizeForSize(size: CGSize) -> CGSize {
        var scale = UIScreen.mainScreen().scale
        return CGSize(width: (size.width * scale), height: (size.height * scale))
    }
}