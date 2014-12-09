//
//  NSDate.swift
//  leexplorer
//
//  Created by Hector Monserrate on 26/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

extension NSDate {
    
    
    class func leFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ'"
        
        return dateFormatter
    }
    
    class func leDateFromString(string: String) -> NSDate? {
        return leFormatter().dateFromString(string)
    }
    
    func leString() -> String {
        return self.dynamicType.leFormatter().stringFromDate(self)
    }
}