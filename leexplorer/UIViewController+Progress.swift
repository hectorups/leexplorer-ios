//
//  UIViewController+Progress.swift
//  leexplorer
//
//  Created by Hector Monserrate  on 12/8/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation
//
//  UINavigationController+Progress.swift
//  leexplorer
//
//  Created by Hector Monserrate  on 12/8/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation
import ObjectiveC

private var indeterminateProgressAssociationKey: UInt8 = 0

extension UIViewController {
    
    var overlayProgressView: MRProgressOverlayView? {
        get {
            return objc_getAssociatedObject(self, &indeterminateProgressAssociationKey) as? MRProgressOverlayView
        }
        
        set(value) {
            objc_setAssociatedObject(self, &indeterminateProgressAssociationKey, value, UInt(OBJC_ASSOCIATION_RETAIN))
        }
    }
    
    func progressStartAnimating() {
        progressStartAnimatingWithTitle("")
    }
    
    func progressStartAnimatingWithTitle(title: String) {
        overlayProgressView = MRProgressOverlayView()
        overlayProgressView!.tintColor = ColorPallete.Blue.get()
        self.view.addSubview(overlayProgressView!)
        overlayProgressView!.titleLabelText = title
        overlayProgressView!.show(true)
    }
    
    func progressStopAnimating() {
        overlayProgressView?.dismiss(true)
    }
    
    func performBlockAfterDelay(delay: NSTimeInterval, block: () -> Void ) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue(), block)
    }
}