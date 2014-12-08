//
//  UINavigationController+Progress.swift
//  leexplorer
//
//  Created by Hector Monserrate  on 12/8/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation
import ObjectiveC

private var indeterminateNavProgressAssociationKey: UInt8 = 0

extension UINavigationController {
    var navProgressView: GSIndeterminateProgressView! {
        get {
            return objc_getAssociatedObject(self, &indeterminateNavProgressAssociationKey) as? GSIndeterminateProgressView
        }
        
        set(value) {
            objc_setAssociatedObject(self, &indeterminateNavProgressAssociationKey, value, UInt(OBJC_ASSOCIATION_RETAIN))
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let progressHeight: CGFloat = 4.0
        navProgressView = GSIndeterminateProgressView(frame: CGRectMake(0, navigationBar.frame.size.height - progressHeight, navigationBar.frame.size.width, progressHeight))
        navProgressView.progressTintColor = ColorPallete.Blue.get()
        navProgressView.autoresizingMask = .FlexibleWidth | .FlexibleTopMargin
        navProgressView.hidden = true
        
        navigationBar.addSubview(navProgressView)
    }
    
    func navProgressStartAnimating() {
        navProgressView.startAnimating()
    }
    
    func navProgressStopAnimating() {
        navProgressView.stopAnimating()
    }
    
}