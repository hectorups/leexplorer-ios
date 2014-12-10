//
//  UIImage+Extensions.swift
//  leexplorer
//
//  Created by Hector Monserrate on 03/12/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

private var uiImageFromModelNonAtomicKey: UInt8 = 2

extension UIImageView {
    
    // MARK: - Fix Template Image for ios 7
    func fixTemplateImage() {
        self.image = self.image?.fixTemplateImage()
    }
    
    func setImageWithImageModel(image: Image, width: Int, height: Int, galleryId: String) {
        setImageWithImageModel(image, width: width, height: height, galleryId: galleryId) { (image) -> Void in
            self.image = image
        }
    }
    
    // MARK: - Image Picker
    
    var imageLoading: Image? {
        get {
            return objc_getAssociatedObject(self, &uiImageFromModelNonAtomicKey) as? Image
        }
        
        set(value) {
            objc_setAssociatedObject(self, &uiImageFromModelNonAtomicKey, value, UInt(OBJC_ASSOCIATION_RETAIN))
        }
    }
    
    func setImageWithImageModel(image: Image, width: Int, height: Int, galleryId: String, block: (image: UIImage) -> Void) {
        let bestSize = leBestSizeFor(width, height: height)
        
        imageLoading = image
        if MediaManager.imageExists(image, size: bestSize, galleryId: galleryId) {
            LELog.d("image loaded from file \(bestSize.hashValue)")
            let localUrl = MediaManager.localUrlForImage(image, size: bestSize, galleryId: galleryId)!
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
            dispatch_async(queue) { () -> Void in
                let uiImage = UIImage(contentsOfFile: localUrl)!
                UIGraphicsBeginImageContext(CGSizeMake(1, 1))
                let context = UIGraphicsGetCurrentContext()
                CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), uiImage.CGImage)
                UIGraphicsEndImageContext()
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if self.imageLoading == image {
                        block(image: uiImage)
                    }
                    self.imageLoading = nil
                })
            }
        } else {
            LELog.d("image loaded from net")
            let imageUrl = MediaProcessor.urlForImageFill(image, width: width, height: height)
            let urlRequest = NSURLRequest(URL: imageUrl)
            self.setImageWithURLRequest(NSURLRequest(URL: imageUrl)
                , placeholderImage: nil
                , success: {(request, response, uiImage) -> Void in
                    if self.imageLoading == image {
                        block(image: uiImage)
                        self.imageLoading = nil
                    }
                }) { (request, response, error) -> Void in
                    LELog.e(error)
                }
        }
    }
    
    private func leBestSizeFor(width: Int, height: Int) -> MediaManager.Size {
        let sizes = MediaManager.Size.allValues.reverse() // From small to big
        
        for size in sizes {
            println("File \(size.hashValue) -> \(size.width()) - \(size.height())  > \(width) - \(height) ?")
            if size.width() >= CGFloat(width) && size.height() >= CGFloat(height) {
                return size
            }
        }
        
        return sizes.last!
    }
}