//
//  UIImage+Extensions.swift
//  leexplorer
//
//  Created by Hector Monserrate on 03/12/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

extension UIImageView {
    func fixTemplateImage() {
        self.image?.imageWithRenderingMode(.AlwaysTemplate)
    }
}