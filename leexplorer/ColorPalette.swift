//
//  ColorPalette.swift
//  leexplorer
//
//  Created by Hector Monserrate on 25/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

enum ColorPallete {
    case
    White,
    Black,
    DarkGrey,
    MidGrey,
    LightGreyBg,
    Blue,
    AppBg
    
    func get() -> UIColor {
        switch self {
        case .White:
            return UIColor(hexString: "#FFFFFE");
        case .Black:
            return UIColor(hexString: "#333333");
        case .DarkGrey:
            return UIColor(hexString: "#747474");
        case .MidGrey:
            return UIColor(hexString: "#ABABAB");
        case .LightGreyBg:
            return UIColor(hexString: "#F1F4F2");
        case .Blue:
            return UIColor(hexString: "#0098C6");
        case AppBg:
            return UIColor(hexString: "#F0F0F0")
        }
    }
    
}