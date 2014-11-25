//
//  LELog.swift
//  leexplorer
//
//  Created by Hector Monserrate on 24/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

class LELog {
    
    class func d(object: AnyObject!) {
        if AppConstant.DEBUG {
            println(object)
        }
    }
    
    class func e(object: AnyObject!) {
        LELog.d(object)
    }
}