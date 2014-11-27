//
//  ArtworkViewController.swift
//  leexplorer
//
//  Created by Hector Monserrate on 26/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import UIKit

class ArtworkProfileViewController: UIViewController {
    
    var artwork: Artwork!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = artwork.name
        // Do any additional setup after loading the view.
    }
    


}
