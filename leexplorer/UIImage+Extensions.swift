//
//  UIImage+Extensions.swift
//  leexplorer
//
//  Created by Hector Monserrate  on 12/6/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

extension UIImage {
    func fixTemplateImage() -> UIImage {
        return self.imageWithRenderingMode(.AlwaysTemplate)
    }
    
    func withColorTint(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        var context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextSetBlendMode(context, kCGBlendModeNormal)
        let rect = CGRectMake(0, 0, self.size.width, self.size.height)
        CGContextClipToMask(context, rect, self.CGImage)
        color.setFill()
        CGContextFillRect(context, rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}