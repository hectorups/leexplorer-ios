//
//  UIButton+Extensions.swift
//  leexplorer
//
//  Created by Hector Monserrate on 03/12/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

extension UIButton {
    func fixTemplateImage() {
        if let image = imageView?.image {
            setImage(
                image.fixTemplateImage(),
                forState: .Normal)
        }
    }
}