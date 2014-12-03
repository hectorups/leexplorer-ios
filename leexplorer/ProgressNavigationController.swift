//
//  ProgressNavigationController.swift
//  leexplorer
//
//  Created by Hector Monserrate on 02/12/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import UIKit

class ProgressNavigationController: UINavigationController {
    var progressView: GSIndeterminateProgressView!
    
    let PROGRESS_HEIGHT: CGFloat = 4.0

    override func viewDidLoad() {
        super.viewDidLoad()

        progressView = GSIndeterminateProgressView(frame: CGRectMake(0, navigationBar.frame.size.height - PROGRESS_HEIGHT, navigationBar.frame.size.width, PROGRESS_HEIGHT))
        progressView.progressTintColor = ColorPallete.Blue.get()
        progressView.autoresizingMask = .FlexibleWidth | .FlexibleTopMargin
        progressView.hidden = true
        
        navigationBar.addSubview(progressView)
    }
    
    func startAnimating() {
        progressView.startAnimating()
    }
    
    func stopAnimating() {
        progressView.stopAnimating()
    }

}
