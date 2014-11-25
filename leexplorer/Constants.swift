//
//  Constants.swift
//  leexplorer
//
//  Created by Hector Monserrate on 24/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

struct AppConstant {
    static let App = UIApplication.sharedApplication().delegate as AppDelegate
    static let CLIENT_VERSION = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as String

    #if DEBUG
        static let DEBUG = true
        static let LEEXPLORER_ENDPOINT = "https://leexplorer.herokuapp.com"
    #else
        static let DEBUG = false
        static let LEEXPLORER_ENDPOINT = "https://leexplorer.herokuapp.com"
    #endif

    static let LE_UUID = "9133edc4-a87c-5529-befa-4f75f31a45d4"

    static let CLOUDINARY_CLOUD_NAME = "leexplorer"
    static let MIXPANEL_TOKEN = "b66f535a8b703ce67e53b646b99de279"
    static let GOOGLE_ANALYTICS_ID = "UA-53532539-1"

    static let BUILD_KILLED_MESSAGE = "Client update required, min build:"
    static let CLIENT_BUILD_HEADER_KEY = "X-LeExplorer-Client"
    static let CLIENT_NAME = "LeExplorer-iOS"

    static let MIN_METRES_FOR_AUTOPLAY = 20
    static let MILSEC_ARTWORK_REFRESH = 30000
}
