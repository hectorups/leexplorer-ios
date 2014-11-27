//
//  NSDateFormatter+LeFormater.swift
//  leexplorer
//
//  Created by Hector Monserrate on 27/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

extension NSDateFormatter {
    class var leShared : NSDateFormatter {
        struct Static {
            static var instance: NSDateFormatter {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "YYYY"
                return dateFormatter
            }
        }
        return Static.instance
    }
}