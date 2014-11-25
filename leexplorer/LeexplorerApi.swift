//
//  LeexplorerApi.swift
//  leexplorer
//
//  Created by Hector Monserrate on 24/11/14.
//  Copyright (c) 2014 leexplorer. All rights reserved.
//

import Foundation

class LeexplorerApi: AFHTTPSessionManager {
    
    typealias SuccessHandler = (operation: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void
    typealias FailHandler = (operation: NSURLSessionDataTask!, error: NSError!) -> Void
    
    class var shared : LeexplorerApi {
        struct Static {
            static let instance = LeexplorerApi(baseURL: NSURL(string: AppConstant.LEEXPLORER_ENDPOINT))
        }
        return Static.instance
    }
    
    override init!(baseURL url: NSURL!) {
        super.init(baseURL: url)
        self.requestSerializer = AFJSONRequestSerializer(writingOptions: nil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK - REQUEST INTERCEPTOR

    override func dataTaskWithRequest(request: NSURLRequest!, completionHandler: ((NSURLResponse!, AnyObject!, NSError!) -> Void)!) -> NSURLSessionDataTask! {
        var mutableRequest = request as NSMutableURLRequest
        mutableRequest.addValue("\(AppConstant.CLIENT_NAME)/\(AppConstant.CLIENT_VERSION)",
            forHTTPHeaderField: AppConstant.CLIENT_BUILD_HEADER_KEY)
        
        return super.dataTaskWithRequest(mutableRequest, completionHandler: completionHandler)
    }

   
    // MARK: - LE API
    
    override func GET(URLString: String!, parameters: AnyObject!, success: ((NSURLSessionDataTask!, AnyObject!) -> Void)!, failure: ((NSURLSessionDataTask!, NSError!) -> Void)!) -> NSURLSessionDataTask! {
        LELog.d("GET API call: \(URLString)")
        LELog.d(parameters)
        return self.GET(URLString, parameters: parameters, success: success, failure: failure)
    }
    
}