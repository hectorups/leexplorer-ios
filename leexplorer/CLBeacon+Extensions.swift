//
//  CLBeacon+Extensions.swift
//  leexplorer
//
//  Created by Hector Monserrate  on 12/14/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation
import CoreLocation

extension CLBeacon {
    func leNormalizedAccuracy() -> Double {
        return accuracy > 0.0 ? accuracy : DBL_MAX - 1
    }
}