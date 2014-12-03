//
//  SDKVersion.swift
//  leexplorer
//
//  Created by Hector Monserrate on 02/12/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

class SDKVersion {
    
    class func greaterOrEqualTo(version: NSString) -> Bool {
        return UIDevice.currentDevice().systemVersion.compare(version,
            options: NSStringCompareOptions.NumericSearch) != NSComparisonResult.OrderedAscending
    }
    
}